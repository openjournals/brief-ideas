class AddScoreToIdea < ActiveRecord::Migration
  def change
    add_column :ideas, :score, :float, :default => 0.0
    add_index(:ideas, :score)
  end
end
