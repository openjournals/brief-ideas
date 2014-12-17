class AddViewCountToIdea < ActiveRecord::Migration
  def change
    add_column :ideas, :view_count, :integer, :default => 0
    add_index :ideas, :view_count
  end
end
