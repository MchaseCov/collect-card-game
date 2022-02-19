class AddUniqueIndexToKeywords < ActiveRecord::Migration[7.0]
  def change
    add_index :keywords, %i[type party_card_parent_id], unique: true
  end
end
