class CreateProjectDesigners < ActiveRecord::Migration[8.0]
  def change
    create_table :projects_designers do |t|
      t.integer :designer_id
      t.integer :project_id
      t.timestamps
    end
  end
end
