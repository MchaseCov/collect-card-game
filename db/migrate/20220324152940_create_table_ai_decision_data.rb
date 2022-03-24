class CreateTableAiDecisionData < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_decision_data do |t|
      t.string :type
      t.json :card_weight
      t.references :card_constant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
