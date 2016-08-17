#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require "sinatra/reloader" # remove when deployed
require 'haml'
require 'sass'
require 'kramdown'
require 'rouge'
require 'octokit'
require 'securerandom'
require 'fileutils'
require_relative "repo"

# Provide authentication credentials
github = Octokit::Client.new(:access_token => ENV["LIBREIMBOT_TOKEN"])

get "/" do
  redirect to("/post")
end

get "/post" do
  erb :layout, layout: false do
    haml :post
  end
end

get "/resource" do
  haml :resource
end

get "/style.css" do
  scss :style
end

post "/resource" do
  # Get parameters from request
  title = params[:title]
  author = params[:author]
  link = params[:link]
  # section = params[:section]
  # category = params[:category]

  repo = "libreimbot/awesome"
  base = "gh-pages"
  head = "new-resource-#{SecureRandom.uuid}"

  begin
    modify_repo repo, head, "Nuevo recurso: #{title}" do
      # Add resource to unclassified
      File.open("_common/unclassified.md", "a") do |file|
        file.puts(if link.empty?
          "**#{title}** - #{author}  "
        else
          "[#{title} - #{author}](#{link})  "
        end)
      end
    end

    # Finally, create a pull request using octokit
    github.create_pull_request(repo, base, head, "Nuevo recurso: #{title}", "Añade *[#{title}](#{link})* de #{author}.")
  rescue StandardError => e
  end

  # Return the user to the home page
  # TODO: show success status (and link to new pull request)
  redirect to("/")
end

post "/post" do
  # Get parameters from request
  title = params[:title]
  author = params[:author]
  content = params[:content]
  category = params[:category] || "unclassified"

  date = Date.today.strftime "%Y-%m-%d"
  filename = title.downcase.split(" ")[0..4].join(" ")

  subs = {
    "á" => "a",
    "é" => "e",
    "í" => "i",
    "ó" => "o",
    "ú" => "u",
    /[^a-z ]/ => "",
    " " => "-"
  }

  subs.each do |k, v|
    filename.gsub! k, v
  end

  repo = "libreimbot/blog"
  base = "gh-pages"
  head = "new-post-#{filename}"

  modify_repo repo, head, "Nuevo post: #{title}" do
    File.open("_posts/#{date}-#{filename}.md", "w") do |f|
      f.write <<EOF
---
layout: post
title: #{title}
authors:
- #{author}
category: #{category}
---

#{content}
EOF
    end
  end

  # Finally, create a pull request using octokit
  github.create_pull_request(repo, base, head, "Nuevo post: #{title}", "Añade *#{title}* de #{author}.")

  # Return the user to the home page
  # TODO: show success status (and link to new pull request)
  redirect to("/")
end

post "/preview" do
  Kramdown::Document.new(params[:content], syntax_highlighter: :rouge).to_html
end
