#=======================================|SPELL CARD GAMESTATE TABLE SCHEMA|=======================================
#
# table name: cards
#
# id                      :bigint       null: false, primary key
# cost                    :integer
# health                  :integer      NULL FOR SPELL
# attack                  :integer      NULL FOR SPELL
# health_cap              :integer      NULL FOR SPELL
# location                :string
# status                  :string
# position                :integer
# type                    :string       STI reference column              SPELL CARD
# gamestate_deck_id       :bigint       null: false, foreign key
# card_constant_id        :bigint       null: false, foreign key
# timestamps              :datetime
class SpellCard < Card
  attr_accessor :current_target

  # CALLBACKS ===========================================================
  after_update :do_cast, if: proc { |card|
                               card.saved_change_to_status == %w[unplayed spent]
                             }

  # ASSOCIATIONS ===========================================================
  # PLAYER
  has_one :player, through: :gamestate_deck
  # KEYWORDS
  has_one :cast_effect, through: :card_constant

  def decorate
    SpellCardDecorator.new(self)
  end

  def spend_spell
    move_to_graveyard and status_spent
  end

  private

  def status_spent
    update(status: 'spent')
  end

  def do_cast
    cast_effect.trigger(self, current_target)
  end
end
