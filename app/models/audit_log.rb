class AuditLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :idea

  # These are the only valid auditable actions
  validates_inclusion_of :action, :in => ['tweeted', 'published', 'rejected', 'muted']

end
