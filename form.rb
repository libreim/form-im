#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'octokit'
require 'git'

get '/' do
  haml :index
end


post '/' do
  title = params[:title]
  author = params[:author]
  link = params[:link]

  ## OCTOKIT
  # Provide authentication credentials
  github = Octokit::Client.new(:access_token => ENV["LIBREIMBOT_TOKEN"])
  #repo = "m42/form-im"
  repo = "libreim/herramientas-im"
  base = "master" # "gh-pages" for blog and awesome
  ref_base = "heads/#{base}"
  head = "libreimbot:new-post"
  ref_head = "heads/#{head}"

  g = Git.clone("https://github.com/#{repo}.git", "forms")
  g.branch(head)
  g.checkout(head)
  g.chdir do
    new_file("hey-test", "HEY")
  end
  g.add(all: true)
  g.commit("This is a test!")
  # g.push
  sha_commit = github.ref(repo, ref_head).object.sha
  puts sha_commit
  github.update_ref(repo, ref_head, sha_commit)

  github.create_pull_request(repo, base, head, "This is an automated pull request!", "This is the body of an **automated** pull request. Exciting, isn't it?")

  # now what?

  # ref = 'heads/master'
  # sha_latest_commit = github.ref(repo,ref).object.sha
  # sha_base_tree = github.commit(repo, sha_latest_commit).commit.tree.sha
  #
  # # Filename
  # file_name = File.join("some_dir","testfile")
  # blob_sha = github.create_blob(repo,Base64.encode64(my_content),"base64")
  # sha_new_tree = github.create_tree(repo,
  #                                   [ { :path => file_name,
  #                                       :mode => "100644",
  #                                       :type => "blob",
  #                                       :sha  => blob_sha } ],
  #                                   { :base_tree => sha_base_tree }).sha
  # # Create new commit
  # commit_message = "Commited via Octokit!"
  # sha_new_commit = github.create_commit(repo,
  #                                       commit_message,
  #                                       sha_new_tree,
  #                                       sha_last_commit).sha
  # updated_ref = github.update_ref(repo,ref,sha_new_commit)
  # puts.updated_ref


  haml :index
end
