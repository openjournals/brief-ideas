class Add < ActiveRecord::Migration
  def change
    add_column :ideas, :subject, :string
    add_column :ideas, :tags, :string, array: true, default: []
    add_column :users, :extra, :hstore
  end
end
