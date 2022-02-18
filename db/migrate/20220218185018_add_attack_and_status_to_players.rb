class AddAttackAndStatusToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :attack_current, :integer, default: 0
    add_column :players, :status, :string, default: 'default'
  end
end
