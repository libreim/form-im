#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'octokit'
require 'git'
require 'securerandom'
require 'fileutils'

# Provide authentication credentials
github = Octokit::Client.new(:access_token => ENV["LIBREIMBOT_TOKEN"])

get "/" do
  haml :index
end

post "/resource" do
  # Get parameters from request
  title = params[:title]
  author = params[:author]
  link = params[:link]
  # section = params[:section]
  # category = params[:category]

  repo = "libreim/awesome"
  base = "gh-pages"
  ref_base = "heads/#{base}"
  head = "new-resource-#{SecureRandom.uuid}"
  ref_head = "heads/#{head}"

  dir = "awesome"

  # Basically, there's no way for git to work directly with an access token,
  # so GitHub accepts it as an username
  # http://stackoverflow.com/a/24558935/5306389
  begin
    g = Git.clone("https://#{ENV["LIBREIMBOT_TOKEN"]}@github.com/#{repo}.git", dir)

    # Use the bot's name and email
    g.config("user.name", "libreimbot")
    g.config("user.email", 'libreim.blog@gmail.com')
    # Create the new branch
    g.branch(head).checkout

    g.chdir do
      # Add resource to unclassified
      File.open("_common/unclassified.md", "a") do |file|
        file.puts(if link.empty?
          "**#{title}** - #{author}  "
        else
          "[#{title} - #{author}](#{link})  "
        end)
      end
    end

    # Commit and push to new branch
    g.add(all: true)
    g.commit("Nuevo recurso: #{title}")
    g.push("origin", head)

    # Finally, create a pull request using octokit
    github.create_pull_request(repo, base, head, "Nuevo recurso: #{title}", "Añade *[#{title}](#{link})* de #{author}.")
  rescue StandardError => e
  end
  FileUtils.rm_rf(dir)

  # Return the user to the home page
  # TODO: show success status (and link to new pull request)
  redirect to("/")
end
