class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.references  :user
      t.string      :name
      t.timestamps
    end

    add_index :collections, :user_id
  end
end
