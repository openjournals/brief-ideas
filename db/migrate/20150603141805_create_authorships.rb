class CreateAuthorships < ActiveRecord::Migration
  def change
    create_table :authorships do |t|
      t.integer :user_id
      t.integer :idea_id
      t.timestamps
    end

    add_index :authorships, :user_id
    add_index :authorships, :idea_id
  end
end
