class RemoveParentIdFromIdea < ActiveRecord::Migration
  def change
    remove_column :ideas, :parent_id
  end
end
