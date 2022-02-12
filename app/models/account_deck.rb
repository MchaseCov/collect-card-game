#=======================================|ACCOUNT DECK TABLE SCHEMA|=======================================
#
# table name: account_decks
#
# id                      :bigint       null: false, primary key
# name                    :string
# user_id                 :bigint       null: false, foreign key of User table
# card_count              :integer
# archetype_id            :bigint       null: false, foreign key of Archetype table
# race_id                 :bigint       null: false, foreign key of Race table
#
class AccountDeck < ApplicationRecord
  after_touch do
    broadcast_update_later_to self, target: "account_deck_#{id}"
  end
  validates_presence_of :name
  validates :card_count, numericality: { in: 0..30 }

  has_many :account_deck_party_card_parents
  has_many :party_card_parents, through: :account_deck_party_card_parents
  belongs_to :user
  belongs_to :archetype
  belongs_to :race

  def add_party_card(card)
    return if card_count >= 30
    return unless card.archetype.name == 'Neutral' || card.archetype.name == archetype.name

    party_card_parents << card
    increment!(:card_count)
    touch if persisted?
  end

  def destroy_party_card(card)
    account_deck_party_card_parents.find_by(party_card_parent: card).delete
    decrement!(:card_count)
    touch
  end

  def cards
    party_card_parents # .or(action_card_parents);
  end
end
