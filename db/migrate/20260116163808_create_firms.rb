class CreateFirms < ActiveRecord::Migration[8.0]
  def change
    create_table :firms do |t|
      t.string :name
      t.string :website_url
      t.string :owner_id
      t.timestamps
    end
  end
end
