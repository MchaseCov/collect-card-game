class AddSilencedToCards < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :silenced, :boolean, default: false
  end
end
