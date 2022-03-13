class AddUniqueIndexToKeywords < ActiveRecord::Migration[7.0]
  def change
    add_index :keywords, %i[type card_constant_id], unique: true
  end
end
