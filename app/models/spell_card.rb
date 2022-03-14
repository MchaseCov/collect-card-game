#=======================================|SPELL CARD GAMESTATE TABLE SCHEMA|=======================================
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
# type                    :string       STI reference column              SPELL CARD
# gamestate_deck_id       :bigint       null: false, foreign key
# card_constant_id        :bigint       null: false, foreign key
# timestamps              :datetime
class SpellCard < Card
end
