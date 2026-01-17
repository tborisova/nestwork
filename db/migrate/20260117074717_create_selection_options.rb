class CreateSelectionOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :selection_options do |t|
      t.references :selection, null: false, foreign_key: true
      t.string :name
      t.string :link
      t.integer :price

      t.timestamps
    end
  end
end
