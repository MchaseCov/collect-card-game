class AddIndexOnTypeToKeywords < ActiveRecord::Migration[7.0]
  def change
    add_index :keywords, :type
  end
end
