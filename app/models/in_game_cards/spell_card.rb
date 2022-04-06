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

  after_update do |card|
    card.cast_effect.trigger(self, current_target) if card.saved_change_to_status == %w[unplayed spent]
  end

  enum status: { unplayed: 0, discarded: 1, spent: 2 }, _prefix: true

  has_one :player, through: :gamestate_deck
  has_many :keywords, through: :card_constant do
    def cast_effect
      where(type: 'Cast')
    end
  end

  def cast_effect
    keywords.cast_effect.first
  end

  def decorate
    SpellCardDecorator.new(self)
  end

  private

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
    in_graveyard!
    status_spent!
  end
end
