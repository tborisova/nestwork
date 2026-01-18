class CreatePendingProductOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :pending_product_options do |t|
      t.references :pending_product, null: false, foreign_key: true
      t.string :name
      t.string :link
      t.integer :price

      t.timestamps
    end
  end
end
