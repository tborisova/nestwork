class CreateFirmClients < ActiveRecord::Migration[8.0]
  def change
    create_table :firms_clients do |t|
      t.integer :firm_id
      t.integer :client_id
      t.timestamps
    end
  end
end
