class SwitchToBcrypt < ActiveRecord::Migration[8.0]
  def change
    # Add password_digest column for has_secure_password
    add_column :users, :password_digest, :string

    # Remove old password columns
    remove_column :users, :password_salt, :string
    remove_column :users, :password_hash, :string

    # Make password_digest required
    change_column_null :users, :password_digest, false
  end
end
