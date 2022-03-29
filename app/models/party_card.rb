#=======================================|PARTY CARD GAMESTATE TABLE SCHEMA|=======================================
#
# table name: cards
#
# id                      :bigint       null: false, primary key
# cost                    :integer
# health                  :integer
# attack                  :integer
# health_cap              :integer
# location                :string
# status                  :string
# position                :integer
# type                    :string       STI reference column              PARTY CARD
# gamestate_deck_id       :bigint       null: false, foreign key
# card_constant_id        :bigint       null: false, foreign key
# timestamps              :datetime
class PartyCard < Card
  attr_accessor :current_target

  # CALLBACKS ===========================================================
  after_update :do_battlecry, if: proc { |card|
    card.saved_change_to_location == %w[hand battle] && card.battlecry
  }
  after_update :do_taunt, if: proc { |card|
    card.saved_change_to_location == %w[hand battle] && card.taunt
  }

  after_update :silence, if: proc { |card|
    card.saved_change_to_location == %w[battle hand] && card.buffs.any?
  }

  # ASSOCIATIONS ===========================================================
  # PLAYER
  has_one :player, through: :gamestate_deck
  # KEYWORDS
  # KEYWORD
  has_many :keywords, through: :card_constant do
    def battlecry
      find_by(type: 'Battlecry')
    end

    def taunt
      find_by(type: 'Taunt')
    end

    def deathrattle
      find_by(type: 'Deathrattle')
    end
  end

  def battlecry
    keywords.battlecry
  end

  def taunt
    keywords.taunt
  end

  def deathrattle
    keywords.deathrattle
  end

  # ALIAS AND SCOPES ===========================================================
  # TRIBE
  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { includes(:card_constant).where('card_constant.tribe': tribe) }
  end

  # STATUS
  %i[in_play attacking dead discarded].each do |status|
    scope "is_#{status}".to_sym, -> { where(status: status) }
  end

  scope :in_attack_mode, -> { where(location: 'battle', status: 'attacking') }
  scope :three_or_less_health, -> { where('health <= 3') } # For use in battlecries

  # VALIDATIONS ===========================================================
  validates_presence_of :health_cap, :health, :attack, :status, :cost
  validates_numericality_of :health_cap, :attack, :cost
  validates :health, numericality: { less_than_or_equal_to: :health_cap }
  # UPDATE METHODS ===========================================================
  # STATUS
  %i[in_play unplayed attacking dead discarded].each do |status|
    define_method "status_#{status}".to_sym do
      update(status: status)
    end
  end

  # INTEGER ATTRIBUTES
  %i[position health_cap health].each do |attribute|
    define_method "increment_#{attribute}".to_sym do |amount = 1|
      increment!(attribute, amount)
    end
    define_method "decrement_#{attribute}".to_sym do |amount = 1|
      decrement!(attribute, amount)
    end
  end

  # METHODS (PUBLIC) ==================================================================
  def put_card_in_battle(position)
    status_in_play
    update(position: position)
    move_to_battle
  end

  def return_to_hand
    status_unplayed
    move_to_hand
    player.cards.in_battle.where('position > ?', position).each(&:decrement_position)
  end

  def take_damage(attack)
    decrement_health(attack)
    put_card_in_graveyard and return id if health <= 0
  end

  def increase_health_cap(amount)
    increment_health_cap(amount) and increment_health(amount)
  end

  def decrease_health_cap(amount)
    self.health_cap -= amount
    self.health = self.health_cap if health > self.health_cap
    save
  end

  def decorate
    PartyCardGamestateDecorator.new(self)
  end

  def summon_copy(amount = 1)
    amount_to_summon = [player.party_cards.in_battle.size, amount].min
    return unless amount_to_summon.positive?

    card_stats = { cost: cost, health: health, attack: attack, health_cap: health_cap, location: 'battle',
                   status: 'in_battle', type: 'PartyCard', card_constant: card_constant, position: position }
    prepare_to_summon_cards(amount_to_summon, card_stats, buffs)
  end

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

  def silence
    buffs.destroy_all
  end

  def taunting?
    buffs.where(name: 'Taunt').exists?
  end

  # METHODS (PRIVATE) ==================================================================
  private

  def prepare_to_summon_cards(amount, card_stats, card_buffs = nil)
    create_space_for_tokens(amount)
    gamestate_deck.generate_cards(amount, card_stats, card_buffs)
  end

  def put_card_in_graveyard
    player.cards.in_battle.where('position >= ?', position).each(&:decrement_position)
    move_to_graveyard and status_dead
  end

  def run_buff_method_on_card(buff)
    return unless buff.target_method

    buff.modifier ? send(buff.target_method, buff.modifier) : send(buff.target_method)
  end

  def run_buff_removal_on_card(buff)
    return unless buff.removal_method

    buff.modifier ? send(buff.removal_method, buff.modifier) : send(buff.removal_method)
  end

  def do_battlecry
    battlecry.trigger(self, current_target)
    self.current_target = nil
  end

  def do_taunt
    keywords.taunt.trigger(self)
  end

  def create_space_for_tokens(amount_to_summon)
    left_token_count = amount_to_summon / 2
    player.cards.in_battle.where('position > ?', position).each { |c| c.increment_position(amount_to_summon) }
    increment_position(left_token_count)
  end
end
