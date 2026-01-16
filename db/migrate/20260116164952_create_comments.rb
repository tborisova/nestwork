class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.integer :product_id
      t.text :comment
      t.boolean :resolved
      t.integer :user_id
      t.timestamps
    end
  end
end
