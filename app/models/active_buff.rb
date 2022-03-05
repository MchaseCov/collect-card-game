class ActiveBuff < ApplicationRecord
  belongs_to :buffs
  belongs_to :buffable
end
