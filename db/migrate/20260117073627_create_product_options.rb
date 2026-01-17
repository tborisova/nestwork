class CreateProductOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :product_options do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name
      t.string :link
      t.integer :price
      t.boolean :selected, default: false

      t.timestamps
    end
  end
end
