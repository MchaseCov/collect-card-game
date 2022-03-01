class AddBodyTextToKeywords < ActiveRecord::Migration[7.0]
  def change
    add_column :keywords, :body_text, :text
  end
end
