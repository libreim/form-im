#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'octokit'
require 'git'

get "/" do
  haml :index
end

post "/" do
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
  head = "libreimbot-new-post"
  ref_head = "heads/#{head}"

  dir = ".herramientas"

  # Basically, there's no way for git to work directly with an access token,
  # so GitHub accepts it as an username
  # http://stackoverflow.com/a/24558935/5306389
  g = Git.clone("https://#{ENV["LIBREIMBOT_TOKEN"]}@github.com/#{repo}.git", dir)

  g.config('user.name', "libreimbot")
  g.config('user.email', 'libreim.blog@gmail.com')
  g.branch(head).checkout
  File.write("#{dir}/hey-test", "HEYA")
  g.add(all: true)
  g.commit("This is a test!")
  g.push("origin", head)

  github.create_pull_request(repo, base, head, "This is an automated pull request!", "This is the body of an **automated** pull request. Exciting, isn't it?")

  haml :index
end

post "/link" do
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
  head = "libreimbot-new-post"
  ref_head = "heads/#{head}"

  dir = ".herramientas"

  # Basically, there's no way for git to work directly with an access token,
  # so GitHub accepts it as an username
  # http://stackoverflow.com/a/24558935/5306389
  g = Git.clone("https://#{ENV["LIBREIMBOT_TOKEN"]}@github.com/#{repo}.git", dir)

  g.config('user.name', "libreimbot")
  g.config('user.email', 'libreim.blog@gmail.com')
  g.branch(head).checkout
  File.write("#{dir}/hey-test", "HEYA")
  g.add(all: true)
  g.commit("This is a test!")
  g.push("origin", head)

  github.create_pull_request(repo, base, head, "This is an automated pull request!", "This is the body of an **automated** pull request. Exciting, isn't it?")

  redirect to("/")
end
