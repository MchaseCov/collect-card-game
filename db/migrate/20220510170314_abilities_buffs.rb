class AbilitiesBuffs < ActiveRecord::Migration[7.0]
  def change
    create_table :abilities_buffs, id: false do |t|
      t.belongs_to :ability, :buff
    end
  end
end
