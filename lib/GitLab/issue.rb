
class GitLab::Issue 
  attr_accessor :title, :labels, :assignee_id, :description, :branch, :iid, :obj_gitlab, :status
  @comments = [] 
  @labels = [] 

  def comments
    @comments
  end

  def comments=obj
    @comments << obj
  end

  def initialize(params = {})
    @title = params[:title]
    @labels = params[:labels] || [] 
    @description = params[:description]
    @branch = params[:branch]
    @comments = []
    @assignee_id = GitLab::User.me["id"]
  end

  def set_default_branch branch
    @description = "* ~default_branch #{branch}\n" + @description
  end

  def create
    params = {}
    params.merge!(title: @title)
    params.merge!(description: @description.to_s)
    params.merge!(labels: @labels.join(','))
    params.merge!(assignee_id: @assignee_id)
    
    # label = params.fetch(:label) || ''
    # assignee_id = params.fetch(:assignee_id) || ''
    print "\nCreate new GitLab issue \n\n".yellow
    url = "projects/#{$GITLAB_PROJECT_ID}/issues" 
    issue_json = GitLab.request_post(url, params)
    @iid = issue_json["iid"]
    print "Issue created with success!\n".green
    print "URL: #{issue_json["web_url"]}\n\n"
  end

  def close
    params = {}
    params.merge!(title: @title)
    params.merge!(state_event: 'close')
    params.merge!(description: @description.to_s)
    params.merge!(labels: @labels.join(','))
    
    url = "projects/#{$GITLAB_PROJECT_ID}/issues/#{@iid}" 
    GitLab.request_put(url, params)
    print "Issue '#{@title}' closed with success!\n".green
  end

  def update
    params = {}
    params.merge!(title: @title)
    params.merge!(description: @description.to_s)
    params.merge!(labels: @labels.join(','))
    params.merge!(assignee_id: @assignee_id)
    
    # label = params.fetch(:label) || ''
    # assignee_id = params.fetch(:assignee_id) || ''
    print "\nUpdate GitLab issue\n\n".yellow
    url = "projects/#{$GITLAB_PROJECT_ID}/issues/#{@iid}" 
    GitLab.request_put(url, params)
    print "Issue updated with success!\n".green
  end

  def self.find_by(search)
    url = "projects/#{$GITLAB_PROJECT_ID}/issues?search=#{search.values[0]}&in=#{search.keys[0]}&state=opened"
    issue_json = GitLab.request_get(url)[0]
    if issue_json
      issue = GitLab::Issue.new
      issue.set_data issue_json
    else
      raise "Issue not found #{search.keys[0]}"
    end
  end 

  def self.find_by_branch(branch)
    url = "projects/#{$GITLAB_PROJECT_ID}/issues?search=#{branch}"
    issue_json = GitLab.request_get(url)[0]
    if issue_json
      issue = GitLab::Issue.new
      issue.set_data issue_json
    else
      raise "Issue not found #{branch}"
    end
  end 

  def self.all
    url = "projects/#{$GITLAB_PROJECT_ID}/issues?state=opened"
    GitLab.request_get(url)
  end

  def self.from_list(list_name)
    url = "projects/#{$GITLAB_PROJECT_ID}/issues?labels=#{list_name}&state=opened"
    issues = []
    issues_gitlab = GitLab.request_get(url)
    issues_gitlab.each do |obj|
      issue = self.new
      issue.set_data(obj)

      issues << issue
    end
    issues
  end

  def merge_requests
    url = "projects/#{$GITLAB_PROJECT_ID}/issues/#{iid}/closed_by"
    GitLab.request_get(url)
  end

  def msg_changelog
    # a.description.match(/(\* \~changelog .*\n)+/).to_a
    description.match(/\* \~changelog .*\n?/).to_s.gsub('* ~changelog ', '') rescue nil
  end

  def add_comment note
    comment = GitLab::Comment.new(issue_iid: @iid, body: note)
    @comments << comment
    comment.create
  end

  def set_data obj
    @iid          = obj["iid"]
    @title        = obj["title"]
    @labels       = obj["labels"]
    @description  = obj["description"]
    @assignee_id  = obj["assignees"][0]["id"]
    @branch       = obj["description"].match(/\* \~default_branch .*\n?/).to_s.gsub('* ~default_branch ', '').chomp.strip rescue nil
    @obj_gitlab   = obj
    self
  end

  def create_link_issue target_issue_iid
    url = "projects/#{$GITLAB_PROJECT_ID}/issues/#{@iid}/links?target_project_id=#{$GITLAB_PROJECT_ID}&target_issue_iid=#{target_issue_iid}"
    GitLab.request_post(url, params)
  end
end