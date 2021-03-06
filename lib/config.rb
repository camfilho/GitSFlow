
begin
  require 'dotenv'
  Dotenv.load(File.join( Dir.pwd, ".env"))
  rescue LoadError
  # Gem loads as it should
end
$GITLAB_PROJECT_ID = ENV['GITLAB_PROJECT_ID']
$GITLAB_TOKEN = ENV['GITLAB_TOKEN']
$GITLAB_URL_API = ENV['GITLAB_URL_API']
$GITLAB_EMAIL = ENV['GITLAB_EMAIL'] == "" ? Open3.popen3("git config --local user.email") { |i, o| o.read }.chomp : ENV['GITLAB_EMAIL']
$GITLAB_LISTS = ENV['GITLAB_LISTS'].split(',') rescue nil
$GITLAB_NEXT_RELEASE_LIST = ENV['GITLAB_NEXT_RELEASE_LIST']
$GIT_BRANCH_MASTER= ENV["GIT_BRANCH_MASTER"]
$GIT_BRANCH_DEVELOP= ENV["GIT_BRANCH_DEVELOP"]
$GIT_BRANCHES_STAGING= ENV["GIT_BRANCHES_STAGING"].split(',') rescue nil