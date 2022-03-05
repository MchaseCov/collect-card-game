#=======================================|BUFF TABLE SCHEMA|=======================================
#
# table name: buffs
#
# id                      :bigint       null: false, primary key
# name                    :string
# target_method           :string
# removal_method          :string
# modifier                :integer
# keyword_id              :bigint      foreign key of keyword, optional: true
#
class Buff < ApplicationRecord
  validates_presence_of :name, :target_method, :removal_method, :modifier

  belongs_to :keyword, optional: true
  has_many :active_buffs
end
