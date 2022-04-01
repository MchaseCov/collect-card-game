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
  has_many :keywords, through: :card_constant do
    def battlecry
      find_by(type: 'Cast')
    end
  end

  def cast_effect
    keywords.cast
  end

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

  def required_currency
    player.resource_current
  end

  def additional_requirements
    []
  end

  def spend_currency_method
    player.method(:spend_resource_on_card)
  end

  def enter_play_tasks
    # WILL NEED A BROADCAST THATS COMPATIBLE game.broadcast_card_play_animations(self)
    spend_spell
  end
end
