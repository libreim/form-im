#!/usr/bin/env ruby
require 'git'

def modify_repo repo, head, commit_msg, &block
  dir = ".repo"
  success = true
  begin
    # Basically, there's no way for git to work directly with an access token,
    # so GitHub accepts it as an username
    # http://stackoverflow.com/a/24558935/5306389
    g = Git.clone("https://#{ENV["LIBREIMBOT_TOKEN"]}@github.com/#{repo}.git", dir)

    # Use the bot's name and email
    g.config("user.name", "libreimbot")
    g.config("user.email", 'libreim.blog@gmail.com')

    # Create the new branch
    g.branch(head).checkout

    # Do whatever inside the repo's directory
    g.chdir do
      block.call
    end

    # Commit and push to new branch
    g.add(all: true)
    g.commit("#{commit_msg}")
    g.push("origin", head)
  rescue StandardError => e
    puts "==> Failed to modify repo #{repo}. Error: #{e}"
    success = false
  end
  FileUtils.rm_rf(dir)

  raise "Failed to modify repo" unless success
end
