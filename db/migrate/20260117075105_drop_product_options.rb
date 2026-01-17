class DropProductOptions < ActiveRecord::Migration[8.0]
  def change
    drop_table :product_options
  end
end
