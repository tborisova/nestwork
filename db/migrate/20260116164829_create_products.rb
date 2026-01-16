class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.integer :room_id
      t.string :name
      t.string :link
      t.integer :price
      t.integer :quantity
      t.string :status
      t.timestamps
    end
  end
end
