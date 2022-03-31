class ActiveListenerCard < ApplicationRecord
  belongs_to :card
  belongs_to :active_listener
end
