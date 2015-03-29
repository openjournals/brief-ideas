class User < ActiveRecord::Base
  has_many :ideas
  has_many :votes
  has_many :audit_logs
  has_many :collections

  before_create :set_sha

  scope :fuzzy_search, -> (name) { where("name ILIKE ?", "%#{name}%")}

  def self.from_omniauth(auth)
    where(:provider => auth.provider, :uid => auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid
      user.name     = auth.info.name
      user.avatar_url = auth.info.image
      user.extra = auth
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) if auth["provider"] == "facebook"
      user.save
    end
  end

  def dismiss!(idea)
    self.seen_idea_ids << idea.id
    self.seen_idea_ids_will_change!
    save
  end

  def voter_for?(idea)
    Vote.where(:user_id => self.id, :idea_id => idea.id).exists?
  end

  def vote_for!(idea)
    Vote.create(:user => self, :idea => idea) unless idea.creator == self
  end

  def to_param
    sha
  end

  def nice_name
    if name
      return name.split(',').collect(&:strip).reverse.join(' ')
    else
      return "Missing Name"
    end
  end

  def orcid_url
    "http://orcid.org/" + uid
  end

  private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
