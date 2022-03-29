class BuffsKeywords < ActiveRecord::Migration[7.0]
  def change
    create_table :buffs_keywords, id: false do |t|
      t.belongs_to :buff, :keyword
    end
    remove_column :buffs, :keyword_id
  end
end
