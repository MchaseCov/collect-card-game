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
  # ASSOCIATIONS ===========================================================
  # PLAYER
  has_one :player, through: :gamestate_deck
end
