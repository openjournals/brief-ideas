class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :collection_ideas
  has_many :ideas, :through => :collection_ideas
  
end
