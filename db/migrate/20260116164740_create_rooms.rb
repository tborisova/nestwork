class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :project_id
      t.string :status
      t.timestamps
    end
  end
end
