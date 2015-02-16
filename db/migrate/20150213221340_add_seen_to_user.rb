class AddSeenToUser < ActiveRecord::Migration
  def change
    add_column :users, :seen_idea_ids, :integer, array: true, default: []
    add_index(:users, :seen_idea_ids, :using => 'gin')
  end
end
