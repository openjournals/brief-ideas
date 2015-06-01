class AddShaToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :sha, :string
    add_index :collections, :sha
  end
end
