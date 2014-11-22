class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.column :user_id, :integer
      t.column :idea_id, :integer

      t.timestamps
    end

    add_index :votes, :user_id
    add_index :votes, :idea_id

    add_column :ideas, :vote_count, :integer, :default => 0
    add_index :ideas, :vote_count
  end
end
