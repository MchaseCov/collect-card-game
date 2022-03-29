#=======================================|BUFF TABLE SCHEMA|=======================================
#
# table name: buffs
#
# id                      :bigint       null: false, primary key
# name                    :string
# target_method           :string
# removal_method          :string
# modifier                :integer
#
class Buff < ApplicationRecord
  validates_presence_of :name
  validates_numericality_of :modifier, allow_nil: true
  validates_uniqueness_of :name
  has_and_belongs_to_many :keywords
  has_many :active_buffs
end
