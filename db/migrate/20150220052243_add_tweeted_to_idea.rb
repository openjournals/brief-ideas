class AddTweetedToIdea < ActiveRecord::Migration
  def change
    add_column :ideas, :tweeted, :boolean, :default => false
  end
end
