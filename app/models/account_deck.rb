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
  # ALIAS AND SCOPES ===========================================================
  alias_attribute :cards, :card_references
  # CALLBACKS  ===========================================================
  after_touch do
    broadcast_update_later_to self, target: "account_deck_#{id}"
  end
  validates_presence_of :name
  validates :card_count, numericality: { in: 0..30 }

  has_many :account_deck_card_references
  has_many :card_references, through: :account_deck_card_references
  belongs_to :user
  belongs_to :archetype
  belongs_to :race

  def add_card(card)
    return if card_count >= 30

    arch = card.card_constant.archetype.name
    return unless arch == 'Neutral' || arch == archetype.name

    card_references << card
    touch if persisted?
  end

  def destroy_card(card)
    account_deck_card_references.find_by(card_reference: card).destroy
    touch
  end

  def destroy_all_cards
    account_deck_card_references.destroy_all
    touch
  end
end
