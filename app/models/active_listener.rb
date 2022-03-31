class ActiveListener < ApplicationRecord
  belongs_to :listener, class_name: :Listener, foreign_key: :keyword_id
  belongs_to :listening_card, class_name: :Card, foreign_key: :card_id
  has_many :active_listener_cards, dependent: :destroy
  has_many :cards, through: :active_listener_cards

  def listening_block
    case listener.listening_condition
    when 'spell_card_played'
      ->(card) { card.saved_change_to_status == %w[unplayed spent] }
    end
  end

  def activate_listener_effect
    listener.activate_effect(listening_card)
  end
end
