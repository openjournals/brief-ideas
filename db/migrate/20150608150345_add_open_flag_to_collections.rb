class AddOpenFlagToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :open, :boolean, :default => false
  end
end
