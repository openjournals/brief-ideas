class AddZenodoFields < ActiveRecord::Migration
  def change
    add_column :ideas, :zenodo_id, :integer
    add_column :ideas, :doi, :string
  end
end
