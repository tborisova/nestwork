class CreateFirmsDesigners < ActiveRecord::Migration[8.0]
  def change
    create_table :firms_designers do |t|
      t.integer :firm_id
      t.integer :designer_id
      t.timestamps
    end
  end
end
