class CreateSelections < ActiveRecord::Migration[8.0]
  def change
    create_table :selections do |t|
      t.references :room, null: false, foreign_key: true
      t.string :name
      t.integer :quantity

      t.timestamps
    end
  end
end
