class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.string  :title
      t.string  :sha
      t.integer :user_id
      t.string  :state
      t.text    :body
      t.integer :parent_id
      t.timestamps
    end
  end
end
