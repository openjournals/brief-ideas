class IdeaReference < ActiveRecord::Base
  belongs_to :idea
  belongs_to :referenced, :class_name => "Idea"
end
