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
  validates_uniqueness_of :name
  validates :resource_type, inclusion: { in: %w[mana energy hybrid] }

  def resource_name
    resource_type == 'hybrid' ? 'Mana and Energy' : resource_type.titleize
  end
end
