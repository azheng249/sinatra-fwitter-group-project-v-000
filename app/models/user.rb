class User < ActiveRecord::Base
  has_many :tweets
  validates :username, presence: true
  validates :email, presence: true
  validates :password, presence: true
  has_secure_password

  def slug
    self.username.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
    self.all.find {|user| user.slug == slug}
  end

end