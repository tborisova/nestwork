class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :firm_id
      t.string :status

      t.timestamps
    end
  end
end
