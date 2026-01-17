class ConvertCommentsToPolymorphic < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :commentable_type, :string
    add_column :comments, :commentable_id, :integer
    add_index :comments, [ :commentable_type, :commentable_id ]
    add_index :comments, :user_id

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE comments
          SET commentable_type = 'Product', commentable_id = product_id
          WHERE product_id IS NOT NULL
        SQL
      end
    end

    remove_column :comments, :product_id, :integer
  end
end
