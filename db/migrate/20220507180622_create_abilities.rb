class CreateAbilities < ActiveRecord::Migration[7.0]
  def change
    create_table :abilities do |t|
      t.string :action
      t.integer :modifier
      t.string :body_text

      t.timestamps
    end
  end
end
