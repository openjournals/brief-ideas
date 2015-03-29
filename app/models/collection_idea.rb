class CollectionIdea < ActiveRecord::Base
  belongs_to :collection
  belongs_to :idea
  
end
