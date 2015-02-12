class AddControlColumnsToIdeas < ActiveRecord::Migration
  def change
    add_column :ideas, :deleted, :boolean, :default => false
    add_column :ideas, :muted, :boolean, :default => false

    add_index :ideas, :deleted
    add_index :ideas, :muted
  end
end
