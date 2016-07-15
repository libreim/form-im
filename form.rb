require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  haml :index
end


post '/' do
  title = params[:title]
  author = params[:author]
  link = params[:link]

  ## OCTOKIT
  # Provide authentication credentials
  repo = 'dgiim/blog'
  ref = 'heads/master'
  client = Octokit::Client.new :login => 'dgiimbot', :password => 'password'
  user = client.user
  user.login
  

  # Create new commit
  create_commit(
    "dgiim/blog",
    "[form] Post: $title",
    "????", # the SHA of the tree object the new commit will point to
    "????", # parent
  )
    
  # Pull request
  client.create_pull_request(
    "dgiim/blog",
    "gh-pages",
    "post-title-branch", ## TODO!
    "Pull request title",
    "Pull request body" ## optional
  )
  
  
  haml :index
end
