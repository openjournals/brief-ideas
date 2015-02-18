class SetDefaultUserSeen < ActiveRecord::Migration
  def change
    change_column_default :users, :seen_idea_ids, [0]
  end
end
