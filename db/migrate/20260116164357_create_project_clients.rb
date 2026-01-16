class CreateProjectClients < ActiveRecord::Migration[8.0]
  def change
    create_table :projects_clients do |t|
      t.integer :client_id
      t.integer :project_id
      t.timestamps
    end
  end
end
