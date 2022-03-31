class AddListeningToToKeywords < ActiveRecord::Migration[7.0]
  def change
    add_column :keywords, :listening_condition, :string
  end
end
