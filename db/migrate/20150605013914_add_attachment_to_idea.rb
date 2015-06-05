class AddAttachmentToIdea < ActiveRecord::Migration
  def change
    add_attachment :ideas, :attachment
  end
end
