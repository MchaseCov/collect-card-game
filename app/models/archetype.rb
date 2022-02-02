#=======================================|ARCHETYPE TABLE SCHEMA|=======================================
#
# table name: races
#
# id                      :bigint       null: false, primary key
# name                    :string
# description             :text
# resource_type           :string
#
class Archetype < ApplicationRecord
  validates_presence_of :name, :description, :resource_type
  validates :resource_type, inclusion: { in: %w[mana energy hybrid] }
end
