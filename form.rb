require 'rubygems'
require 'sinatra'
require 'haml'
require 'octokit'

get '/' do
  haml :index
end


post '/' do
  title = params[:title]
  author = params[:author]
  link = params[:link]

  ## OCTOKIT
  # Provide authentication credentials
  github = Octokit::Client.new(:login => 'dgiimbot', :password => 'password')
  repo = 'm42/dgiim-form'
  ref = 'heads/master'
  sha_latest_commit = github.ref(repo,ref).object.sha
  sha_base_tree = github.commit(repo, sha_latest_commit).commit.tree.sha

  # Filename
  file_name = File.join("some_dir","new_file.txt")
  blob_sha = github.create_blob(repo,Base64.encode64(my_content),"base64")
  sha_new_tree = github.create_tree(repo,
                                    [ { :path => file_name,
                                        :mode => "100644"
                                        :type => "blob"
                                        :sha  => blob_sha } ],
                                    { :base_tree => sha_base_tree }).sha
  # Create new commit
  commit_message = "Commited via Octokit!"
  sha_new_commit = github.create_commit(repo,
                                        commit_message,
                                        sha_new_tree,
                                        sha_last_commit).sha
  updated_ref = github.update_ref(repo,ref,sha_new_commit)
  puts.updated_ref
  

  haml :index
end
