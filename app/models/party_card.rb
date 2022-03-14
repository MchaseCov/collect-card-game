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
                                    card.saved_change_to_location == %w[hand battle] && card.battlecry.present?
                                  }

  # ASSOCIATIONS ===========================================================
  # PLAYER
  has_one :player, through: :gamestate_deck

  # ALIAS AND SCOPES ===========================================================
  # TRIBE
  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { includes(:card_constant).where('card_constant.tribe': tribe) }
  end

  # STATUS
  %i[in_play attacking dead discarded].each do |status|
    scope "is_#{status}".to_sym, -> { where(status: status) }
  end

  # VALIDATIONS ===========================================================
  validates_presence_of :health_cap, :health, :attack, :status, :cost
  validates_numericality_of :health_cap, :attack, :cost
  validates :health, numericality: { less_than_or_equal_to: :health_cap }
  # UPDATE METHODS ===========================================================
  # STATUS
  %i[in_play attacking dead discarded].each do |status|
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
    move_to_battle
    status_in_play
    update(position: position)
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

  # METHODS (PRIVATE) ==================================================================
  private

  def put_card_in_graveyard
    player.cards.in_battle.where('position >= ?', position).each(&:decrement_position)
    move_to_graveyard and status_dead
  end

  def run_buff_method_on_card(buff)
    send(buff.target_method, buff.modifier)
  end

  def run_buff_removal_on_card(buff)
    send(buff.removal_method, buff.modifier)
  end

  def do_battlecry
    battlecry.trigger(self, current_target)
    self.current_target = nil
  end
end
