#=======================================|GAME TABLE SCHEMA|=======================================
#
# table name: races
#
# id                      :bigint       null: false, primary key
# name                    :string
# description             :text
# health_modifier `       :integer
# cost_modifier           :integer
# resource_modifier       :integer`
#

class Race < ApplicationRecord
  validates_presence_of :name, :description, :health_modifier, :cost_modifier, :resource_modifier
  validates :health_modifier, :cost_modifier, :resource_modifier, numericality: { in: -10..10 }
  validates :name, uniqueness: true
end
