class Add < ActiveRecord::Migration
  def change
    add_column :ideas, :subject, :string
    add_column :ideas, :tags, :text
  end
end
