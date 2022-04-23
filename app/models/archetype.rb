#=======================================|ARCHETYPE TABLE SCHEMA|=======================================
#
# table name: races
#
# id                      :bigint       null: false, primary key
# name                    :string
# description             :text
# resource_type           :string
# color                   :string
#
class Archetype < ApplicationRecord
  validates_presence_of :name, :description, :resource_type
  validates_uniqueness_of :name
  validates :resource_type, inclusion: { in: %w[mana energy hybrid] }

  enum color: { slate: 0, sky: 1, emerald: 2, red: 3 }

  def resource_name
    resource_type == 'hybrid' ? 'Mana and Energy' : resource_type.titleize
  end

  def resource_color
    { 'mana' => 'sky', 'energy' => 'rose', 'hybrid' => 'violet' }[resource_type]
  end
end
