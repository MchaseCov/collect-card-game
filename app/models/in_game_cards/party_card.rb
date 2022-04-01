# PartyCards are a child of the Card model through an STI subclass. PartyCards are cards that make up the core
# gameplay by being played, conducting attacks, and invoking special keyword effects.
#=======================================|PARTY CARD TABLE SCHEMA|=======================================
#
# table name: cards
#
# id                      :bigint       null: false, primary key
# cost                    :integer      The amount to deduct from Player.cost_current when played.
# health                  :integer      The current health point total of the PartyCard
# attack                  :integer      The current attack point total of the PartyCard
# health_cap              :integer      The maximum health point total the PartyCard can currently reach
# location                :string       Location of the card relative to the Game
# status                  :string       Information about the card, such as "attacking" or "dead"
# position                :integer      "Physical location" of the card on the game board.
# silenced                :boolean      default: false, indicates if card has been silenced.
# type                    :string       STI reference column === "PartyCard"
# gamestate_deck_id       :bigint       null: false, foreign key
# card_constant_id        :bigint       null: false, foreign key
# timestamps              :datetime
class PartyCard < Card
  # current_target is for setting the chosen target of a player during a Card play with a Battlecry Keyword.
  attr_accessor :current_target
  attr_accessor :chosen_position

  # Callbacks: Evaluate PartyCard column changes after a save is committed to the database.
  #
  # saved_change_to_attrubute? #=> True if 'attribute' has been changed.
  # saved_change_to_location # => Array containing the data before and after the change.
  #                               Example: card.saved_change_to_status # =>['attacking', 'dead']
  after_update do |card|
    if card.saved_change_to_location? && card.saved_change_to_location == %w[hand battle]
      card.battlecry&.trigger(card, card.current_target)
      [card.taunt, card.aura, card.listener].compact.each { |keyword| keyword.trigger(card) }
    end
    if card.saved_change_to_status? && card.saved_change_to_status[1] == 'dead'
      card.deathrattle&.trigger(card) unless card.silenced?
      clean_buffs_and_effects
    end
  end

  # ASSOCIATIONS ===========================================================
  # PLAYER
  has_one :player, through: :gamestate_deck
  # KEYWORDS
  # KEYWORD
  has_many :keywords, through: :card_constant
  %i[battlecry taunt deathrattle aura listener].each do |keyword_type|
    define_method(keyword_type) { keywords.find_by(type: keyword_type.to_s.upcase_first) }
  end
  # ACTIVE LISTENER EFFECTS
  has_one :active_listener_effect, class_name: 'ActiveListener', foreign_key: :card_id

  # SCOPES ===========================================================
  # Scope by tribe tag
  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { includes(:card_constant).where('card_constant.tribe': tribe) }
  end

  # Scope by status of card
  %i[in_play attacking dead discarded].each do |status|
    scope "is_#{status}".to_sym, -> { where(status: status) }
  end

  # Scope by status and location for selecting cards that are able to attack.
  scope :in_attack_mode, -> { where(location: 'battle', status: 'attacking') }

  # VALIDATIONS ===========================================================
  validates_presence_of :health_cap, :health, :attack, :status, :cost
  validates_numericality_of :health_cap, :attack, :cost
  validates :health, numericality: { less_than_or_equal_to: :health_cap }

  # Updates the status column of the Card.
  #
  # Examples
  #   card.move_to_battle
  #   # => UPDATE "cards" SET "status" = $1 ...[["status", "unplayed"]
  #
  # Returns true if SQL transaction is successful.
  %i[in_play unplayed attacking dead discarded].each do |status|
    define_method "status_#{status}".to_sym do
      update(status: status)
    end
  end

  # Increments or decrements integer columns of the Card.
  #
  # amount  - The amount to in/decrement by. Defaults to 1 if no input.
  # Examples
  #   card.decrement_attack(5)
  #   # =>  UPDATE "cards" SET "attack" = COALESCE("attack", 0) - 5 ...
  #
  # Returns true if SQL transaction is successful.
  %i[position health_cap health attack].each do |attribute|
    define_method "increment_#{attribute}".to_sym do |amount = 1|
      increment!(attribute, amount)
    end
    define_method "decrement_#{attribute}".to_sym do |amount = 1|
      decrement!(attribute, amount)
    end
  end

  # put_card_in_battle: Updates a card status to be in play, activate any auras on the card
  # update its location to be in battle, and set its board position to the input.
  #
  # position  - The Integer in range (1..7) for the Card's position on the board.
  def put_card_in_battle(position)
    status_in_play
    buffs << player.auras if player.auras.any?
    update(position: position)
    move_to_battle
  end

  # return_to_hand: Updates a card status to be unplayed, location to the hand, wipes all buffs,
  # and decrements the position of other cards on the board to fill the gap.
  def return_to_hand
    status_unplayed
    move_to_hand
    clean_buffs_and_effects
    player.cards.in_battle.where('position > ?', position).each(&:decrement_position)
  end

  # take_damage: Decrements the health attribute of a Card by the amount supplied.
  # If the health attribute is now less than 0, the card is moved to the graveyard.
  #
  # attack  - The Integer of the recieved attack to decrease the health attribute by.
  def take_damage(attack)
    decrement_health(attack)
    put_card_in_graveyard and return id if health <= 0
  end

  # increase_health_cap: Increase the health cap of a Card by the amount supplied.
  # This also increases the current health of the Card.
  #
  # amount  -  The Integer amount to increase the health attribute value.
  def increase_health_cap(amount)
    increment_health_cap(amount) and increment_health(amount)
  end

  # decrease_health_cap: Decrease the health cap of a Card by the amount supplied.
  # If the current health of the card would be higher the cap, lower it to match the cap.
  #
  # amount  -  The Integer amount to decrease the health attribute value.
  def decrease_health_cap(amount)
    self.health_cap -= amount
    self.health = self.health_cap if health > self.health_cap
    save
  end

  # decorate: For use in view partials to assign specified classes and HTML data attributes.
  # Class is located in '../../decorators/'
  def decorate
    PartyCardGamestateDecorator.new(self)
  end

  # summon_copy: Create a copy of the PartyCard being called upon, directly in battle.
  # The new Card is generated in the Gamestate Deck model, this method simply prepares the data.
  #
  # amount  - the Integer represeting the amount of copies to generate. Defaults to 1 if no input.
  #
  # TODO(4/1/22): Evaluate if there is a more suitable location for this method and related methods.
  def summon_copy(amount = 1)
    amount_to_summon = [player.party_cards.in_battle.size, amount].min
    return unless amount_to_summon.positive?

    card_stats = { cost: cost, health: health, attack: attack, health_cap: health_cap, location: 'battle',
                   status: 'in_battle', type: 'PartyCard', card_constant: card_constant, position: position }
    prepare_to_summon_cards(amount_to_summon, card_stats, buffs)
  end

  # summon_token: Create a copy of the associated token of a card, directly in battle.
  # Token associations are connected on the "card constant" level and are created during database seed.
  # The new Card is generated in the Gamestate Deck model, this method simply prepares the data.
  #
  # amount  - the Integer represeting the amount of copies to generate. Defaults to 1 if no input.
  #
  # TODO(4/1/22): Evaluate if there is a more suitable location for this method and related methods.
  def summon_token(amount = 1)
    token = card_constant.token
    token_reference = token.card_reference
    amount_to_summon = [player.party_cards.in_battle.size, amount].min
    return unless token && amount_to_summon.positive?

    card_stats = { cost: token_reference.cost, health: token_reference.health, attack: token_reference.attack,
                   health_cap: token_reference.health, location: 'battle', status: 'in_battle', type: 'PartyCard',
                   card_constant: token, position: position }
    prepare_to_summon_cards(amount_to_summon, card_stats)
  end

  # silence: Mark a card as silenced and remove all of its personal buffs, auras, and observers.
  # the silenced attribute will disable Deathrattle callbacks when true.
  # AUra buffs that originate from another card on the board will not be silenced, as the aura is still being output.
  # Auras sourced from the silenced target will be silenced, all beneficiaries of the aura lose the associated buff.
  def silence
    update(silenced: true)
    active_buffs.not_aura_source.each { |ab| buffs.destroy(ab.buff) }
    deactivate_listener
    stop_aura
  end

  # taunting?: Check to see if a card has a "taunt" buff.
  # returns true when a taunt buff association is present.
  def taunting?
    buffs.where(name: 'Taunt').exists?
  end

  # increase_stats: increase both the attack and health of a Card by the amount supplied.
  # amount  -  The Integer amount to increase both attributes.
  def increase_stats(amount = 1)
    increase_health_cap(amount)
    increment_attack(amount)
  end

  # decrease_stats: decrease both the attack and health of a Card by the amount supplied.
  # amount  -  The Integer amount to decrease both attributes.
  def decrease_stats(amount = 1)
    decrease_health_cap(amount)
    decrement_attack(amount)
  end

  # put_card_in_graveyard: "kills" a Card by setting its location to "graveyard" and status to "dead".
  # decrements the position of other cards on the board to fill the gap.
  def put_card_in_graveyard
    player.cards.in_battle.where('position >= ?', position).each(&:decrement_position)
    move_to_graveyard
    status_dead
  end

  private

  # PRIVATE create_space_for_tokens: Private method called by prepare_to_summon_cards
  # Increments positions to create "gaps" for newly summoned cards.
  # Given an amount, it will create an equal amount of spaces on the left and right side of the invoking card,
  # favoring the right/greater side when an odd number is supplied.
  #
  # amount  -  The Integer amount of spaces to create
  def create_space_for_tokens(amount_to_summon)
    left_token_count = amount_to_summon / 2
    player.cards.in_battle.where('position > ?', position).each { |c| c.increment_position(amount_to_summon) }
    increment_position(left_token_count)
  end

  # PRIVATE create_space_for_tokens: Private method called by token generation effects.
  # Creates gaps for cards to be summoned.
  # Calls on associated deck to generate the summoned cards.
  #
  # amount      -  The Integer amount of cards to be summoned
  # card_stats  -  Hash object of card stat data
  # card_buffs  -  ActiveRecord_AssociationRelation of buffs to be applied to the created card(s), nil if unsupplied.
  def prepare_to_summon_cards(amount, card_stats, card_buffs = nil)
    create_space_for_tokens(amount)
    gamestate_deck.generate_cards(amount, card_stats, card_buffs)
  end

  # PRIVATE run_buff_method_on_card: Private method called by buffs association callbacks.
  # Sends the target_method of an associated buff onto the Card.
  #
  # buff  -  The Buff object that invoked the callback when added to the Card.
  #
  # Example
  #      A Buff with the target_method: 'increase_health_cap' will call 'increase_health_cap' on the associated Card.
  def run_buff_method_on_card(buff)
    return unless buff.target_method

    buff.modifier ? send(buff.target_method, buff.modifier) : send(buff.target_method)
  end

  # PRIVATE run_buff_removal_on_card: Private method called by buffs association callbacks.
  # Sends the removal_method: of an associated buff onto the Card.
  #
  # buff  -  The Buff object that invoked the callback when removed from the Card.
  #
  # Example
  #      A Buff with the removal_method: 'decrease_health_cap' will call 'decrease_health_cap' on the associated Card.
  def run_buff_removal_on_card(buff)
    return unless buff.removal_method

    buff.modifier ? send(buff.removal_method, buff.modifier) : send(buff.removal_method)
  end

  # PRIVATE deactivate_listener: destroy an associated active_listener_effect
  def deactivate_listener
    active_listener_effect&.destroy
  end

  # PRIVATE stop_aura: destroy an associated aura keyword effect
  def stop_aura
    aura&.stop_aura(self)
  end

  # PRIVATE remove_all_buffs: destroy all associated buffs
  # Written this way to ensure the run_buff_removal_on_card(buff) callback is called
  def remove_all_buffs
    active_buffs.each { |ab| buffs.destroy(ab.buff) }
  end

  # PRIVATE clean_buffs_and_effects: all-in-one method for removing all listeners, auras, and buffs.
  def clean_buffs_and_effects
    deactivate_listener
    stop_aura
    remove_all_buffs
  end

  def spend_currency_method
    player.method(:spend_coins_on_card)
  end

  def required_currency
    player.cost_current
  end

  def additional_requirements
    [(player.party_cards.in_battle.size < 7)]
  end

  def enter_play_tasks
    game.broadcast_card_play_animations(self, chosen_position - 1)
    player.increment_position_of_cards(chosen_position)
    put_card_in_battle(chosen_position)
  end
end
