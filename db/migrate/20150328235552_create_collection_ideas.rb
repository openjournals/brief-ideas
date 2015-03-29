class CreateCollectionIdeas < ActiveRecord::Migration
  def change
    create_table :collection_ideas do |t|
      t.references :idea
      t.references :collection
      t.timestamps
    end

    add_index :collection_ideas, :idea_id
    add_index :collection_ideas, :collection_id
  end
end
