class AddIndexToIdeaStat < ActiveRecord::Migration
  def change
    add_index :ideas, :state
  end
end
