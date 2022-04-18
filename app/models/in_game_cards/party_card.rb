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
  include HasHealth
  include HasAttack
  include Summonable
  attr_accessor :current_target, :chosen_position

  # Callbacks: Evaluate PartyCard column changes after a save is committed to the database.
  #
  # saved_change_to_attrubute? #=> True if 'attribute' has been changed.
  # saved_change_to_location # => Array containing the data before and after the change.
  #                               Example: card.saved_change_to_status # =>['attacking', 'dead']
  after_update do
    if saved_change_to_location? && saved_change_to_location == %w[hand battlefield]
      battlecry&.trigger(self, current_target)
      [taunt, aura, listener].compact.each { |keyword| keyword.trigger(self) }
    end
    if saved_change_to_status? && saved_change_to_status[1] == 'dead'
      deathrattle&.trigger(self) unless silenced?
      clean_buffs_and_effects
    end
  end

  enum status: { unplayed: 0, discarded: 1, dead: 2, sleeping: 3, attack_ready: 4, second_attack_ready: 5 },
       _prefix: true

  has_one :player, through: :gamestate_deck
  has_many :keywords, through: :card_constant

  has_one :battlecry, -> { merge(Keyword.battlecry) }, through: :card_constant, source: :keywords
  has_one :taunt, -> { merge(Keyword.taunt) }, through: :card_constant, source: :keywords
  has_one :deathrattle, -> { merge(Keyword.deathrattle) }, through: :card_constant, source: :keywords
  has_one :aura, -> { merge(Keyword.aura) }, through: :card_constant, source: :keywords
  has_one :listener, -> { merge(Keyword.listener) }, through: :card_constant, source: :keywords

  has_one :active_listener_effect, class_name: 'ActiveListener', foreign_key: :card_id, dependent: :destroy

  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { includes(:card_constant).where('card_constant.tribe': tribe) }
  end

  def increment_position(amount = 1)
    increment!(:position, amount)
  end

  def decrement_position(amount = 1)
    decrement!(:position, amount)
  end

  # put_card_in_battle: Updates a card status to be in play, activate any auras on the card
  # update its location to be in battle, and set its board position to the input.
  #
  # position  - The Integer in range (1..7) for the Card's position on the board.
  def put_card_in_battle(position)
    transaction do
      status_sleeping!
      update(position: position)
      in_battlefield!
      recieve_valid_auras if player.active_auras.any?
    end
  end

  # return_to_hand: Updates a card status to be unplayed, location to the hand, wipes all buffs,
  # and decrements the position of other cards on the board to fill the gap.
  def return_to_hand
    transaction do
      status_unplayed!
      in_hand!
      clean_buffs_and_effects
      player.shift_cards_left(position)
    end
  end

  # decorate: For use in view partials to assign specified classes and HTML data attributes.
  # Class is located in '../../decorators/'
  def decorate
    PartyCardGamestateDecorator
  end

  # silence: Mark a card as silenced and remove all of its personal buffs, auras, and observers.
  # the silenced attribute will disable Deathrattle callbacks when true.
  # AUra buffs that originate from another card on the board will not be silenced, as the aura is still being output.
  # Auras sourced from the silenced target will be silenced, all beneficiaries of the aura lose the associated buff.
  def silence
    transaction do
      update(silenced: true)
      active_buffs.not_aura_source.each { |ab| buffs.destroy(ab.buff) }
      deactivate_listener
      stop_aura
    end
  end

  # increase_stats: increase both the attack and health of a Card by the amount supplied.
  # amount  -  The Integer amount to increase both attributes.
  def increase_stats(health_amount = 1, attack_amount = nil)
    transaction do
      attack_amount ||= health_amount
      increase_health_cap(health_amount)
      increment_attack(attack_amount)
    end
  end

  # decrease_stats: decrease both the attack and health of a Card by the amount supplied.
  # amount  -  The Integer amount to decrease both attributes.
  def decrease_stats(amount = 1)
    transaction do
      decrease_health_cap(amount)
      decrement_attack(amount)
    end
  end

  # put_card_in_graveyard: "kills" a Card by setting its location to "graveyard" and status to "dead".
  # decrements the position of other cards on the board to fill the gap.
  def put_card_in_graveyard
    player.shift_cards_left(position)
    transaction do
      in_graveyard!
      status_dead!
    end
  end

  private

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
    [(player.party_cards.in_battlefield.size < 7)]
  end

  def enter_play_tasks
    player.shift_cards_right(chosen_position)
    put_card_in_battle(chosen_position)
  end

  def die
    put_card_in_graveyard
    game.add_dead_card(id)
  end

  def recieve_valid_auras
    player.active_auras.each { |aa| buffs << aa.buff if id.in? aa.keywords.first.find_target_options(self)[:ids] }
  end

  def begin_taunt
    update(taunt: true)
  end

  def end_taunt
    update(taunt: false)
  end
end
