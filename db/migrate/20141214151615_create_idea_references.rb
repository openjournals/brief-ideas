class CreateIdeaReferences < ActiveRecord::Migration
  def change
    create_table :idea_references do |t|
      t.integer :idea_id
      t.integer :referenced_id
      t.string  :body
      t.timestamps
    end

    add_index :idea_references, :idea_id
    add_index :idea_references, :referenced_id
    add_index :idea_references, :body
  end
end
