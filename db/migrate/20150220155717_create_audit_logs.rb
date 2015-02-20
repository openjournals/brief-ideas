class CreateAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.string  :title
      t.integer :user_id
      t.integer :idea_id
      t.string  :action
      t.timestamps
    end

    add_index :audit_logs, :user_id
    add_index :audit_logs, :idea_id
  end
end
