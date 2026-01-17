class ImproveDatabaseDesign < ActiveRecord::Migration[8.0]
  def change
    # =========================================
    # 1. Fix owner_id type (string -> integer)
    # =========================================
    change_column :firms, :owner_id, :integer

    # =========================================
    # 2. Add NOT NULL constraints
    # =========================================
    change_column_null :firms, :name, false
    change_column_null :products, :room_id, false
    change_column_null :projects, :name, false
    change_column_null :projects, :firm_id, false
    change_column_null :rooms, :name, false
    change_column_null :rooms, :project_id, false
    change_column_null :comments, :user_id, false
    change_column_null :firms_clients, :firm_id, false
    change_column_null :firms_clients, :client_id, false
    change_column_null :firms_designers, :firm_id, false
    change_column_null :firms_designers, :designer_id, false
    change_column_null :projects_clients, :project_id, false
    change_column_null :projects_clients, :client_id, false
    change_column_null :projects_designers, :project_id, false
    change_column_null :projects_designers, :designer_id, false

    # =========================================
    # 3. Add default for comments.resolved
    # =========================================
    change_column_default :comments, :resolved, from: nil, to: false
    change_column_null :comments, :resolved, false, false

    # =========================================
    # 4. Add missing indexes on foreign keys
    # =========================================
    add_index :products, :room_id
    add_index :projects, :firm_id
    add_index :rooms, :project_id
    add_index :firms_clients, :firm_id
    add_index :firms_clients, :client_id
    add_index :firms_designers, :firm_id
    add_index :firms_designers, :designer_id
    add_index :projects_clients, :project_id
    add_index :projects_clients, :client_id
    add_index :projects_designers, :project_id
    add_index :projects_designers, :designer_id

    # =========================================
    # 5. Add unique constraints on join tables
    # =========================================
    add_index :firms_clients, [:firm_id, :client_id], unique: true, name: "index_firms_clients_unique"
    add_index :firms_designers, [:firm_id, :designer_id], unique: true, name: "index_firms_designers_unique"
    add_index :projects_clients, [:project_id, :client_id], unique: true, name: "index_projects_clients_unique"
    add_index :projects_designers, [:project_id, :designer_id], unique: true, name: "index_projects_designers_unique"

    # =========================================
    # 6. Add foreign key constraints
    # =========================================
    add_foreign_key :comments, :users
    add_foreign_key :products, :rooms
    add_foreign_key :projects, :firms
    add_foreign_key :rooms, :projects
    add_foreign_key :firms, :users, column: :owner_id

    add_foreign_key :firms_clients, :firms
    add_foreign_key :firms_clients, :users, column: :client_id
    add_foreign_key :firms_designers, :firms
    add_foreign_key :firms_designers, :users, column: :designer_id

    add_foreign_key :projects_clients, :projects
    add_foreign_key :projects_clients, :users, column: :client_id
    add_foreign_key :projects_designers, :projects
    add_foreign_key :projects_designers, :users, column: :designer_id
  end
end
