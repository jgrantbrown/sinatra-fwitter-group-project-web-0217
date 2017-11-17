class User < ActiveRecord::Base
  has_many :tweets
  has_secure_password

  attr_accessor :slug

  def slug

    username.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')

  end

  def self.find_by_slug(slug)
    User.all.find{|user| user.slug == slug}
  end

end
