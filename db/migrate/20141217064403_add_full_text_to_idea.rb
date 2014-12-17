class AddFullTextToIdea < ActiveRecord::Migration
  def up
    execute "CREATE INDEX ON ideas USING gin(to_tsvector('english', title || ' ' || body));"
  end

  def down
    execute "DROP INDEX ideas_to_tsvector_idx"
  end
end
