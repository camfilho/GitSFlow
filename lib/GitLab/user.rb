class GitLab::User 
  attr_accessor :id, :email, :name

  def initialize(params = {})
    @name = params[:name]
  end

  def self.me 
    GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/users?search=#{$GITLAB_EMAIL}")[0]
  end

  def self.all
    GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/users")
  end

  def to_s
  end


end