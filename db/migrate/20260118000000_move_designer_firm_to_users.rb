# frozen_string_literal: true

class MoveDesignerFirmToUsers < ActiveRecord::Migration[8.0]
  def up
    # Add firm_id to users table
    add_column :users, :firm_id, :integer
    add_index :users, :firm_id
    add_foreign_key :users, :firms

    # Migrate data from firms_designers to users.firm_id
    # A designer can only be in 1 firm, so we take the first association
    execute <<-SQL
      UPDATE users
      SET firm_id = (
        SELECT firm_id
        FROM firms_designers
        WHERE firms_designers.designer_id = users.id
        LIMIT 1
      )
      WHERE id IN (SELECT designer_id FROM firms_designers)
    SQL

    # Drop the firms_designers table
    drop_table :firms_designers
  end

  def down
    # Recreate firms_designers table
    create_table :firms_designers do |t|
      t.integer :firm_id, null: false
      t.integer :designer_id, null: false
      t.timestamps
    end

    add_index :firms_designers, :designer_id
    add_index :firms_designers, [:firm_id, :designer_id], unique: true, name: "index_firms_designers_unique"
    add_index :firms_designers, :firm_id
    add_foreign_key :firms_designers, :firms
    add_foreign_key :firms_designers, :users, column: :designer_id

    # Migrate data back from users.firm_id to firms_designers
    execute <<-SQL
      INSERT INTO firms_designers (firm_id, designer_id, created_at, updated_at)
      SELECT firm_id, id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
      WHERE firm_id IS NOT NULL
    SQL

    # Remove firm_id from users
    remove_foreign_key :users, :firms
    remove_index :users, :firm_id
    remove_column :users, :firm_id
  end
end
