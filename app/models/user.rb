class User < ActiveRecord::Base
  has_many :tweets
  has_secure_password

  attr_accessor :slug

  def slug
    self.username.gsub!(' ','-')
  end

  def self.find_by_slug(slug)
    User.find_by(:slug == slug)
  end

end
