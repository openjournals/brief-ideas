class AddIndexToTags < ActiveRecord::Migration
  def change
    add_index(:ideas, :tags, :using => 'gin')
  end
end
