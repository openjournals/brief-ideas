class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.string  :gist_url
      t.integer :user_id
      t.string  :state
      t.string  :current_sha
      t.timestamps
    end
  end
end
