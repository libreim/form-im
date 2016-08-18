#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
# require "sinatra/reloader" # remove when deployed
require 'haml'
require 'sass'
require 'kramdown'
require 'rouge'
require 'octokit'
require 'securerandom'
require 'fileutils'
require_relative "repo"

set :bind, '0.0.0.0'
set :port, 3002

# Provide authentication credentials
github = Octokit::Client.new(:access_token => ENV["LIBREIMBOT_TOKEN"])

get "/" do
  redirect to("/post/")
end

get "/post/?" do
  haml :post, layout_engine: :erb
end

get "/resource/?" do
  haml :resource, layout_engine: :erb
end

get "/style.css" do
  scss :style
end

post "/resource/?" do
  # Get parameters from request
  title = params[:title]
  author = params[:author]
  link = params[:link]
  description = params[:description].empty? ? "" : " - *#{params[:description]}*"
  # section = params[:section]
  # category = params[:category]

  repo = "libreim/awesome"
  base = "gh-pages"
  head = "new-resource-#{SecureRandom.uuid}"

  begin
    raise "El título no debe estar vacío" if title.empty?
    raise "El autor no debe estar vacío" if author.empty?

    modify_repo repo, head, "Nuevo recurso: #{title}" do
      # Add resource to unclassified
      File.open("_common/unclassified.md", "a") do |file|
        file.puts(if link.empty?
          "**#{title}** - #{author}#{description}  "
        else
          "[#{title} - #{author}](#{link})#{description}  "
        end)
      end
    end

    # Finally, create a pull request using octokit
    response = github.create_pull_request(repo, base, head, "Nuevo recurso: #{title}", "Añade *[#{title}](#{link})* de #{author}.")

    @message = "Tu recurso se ha enviado. <a href=\"#{response.html_url}\">Ver pull request</a>"
    haml :resource, layout_engine: :erb
  rescue StandardError => e
    @error = "Algo ocurrió: <em>#{e}</em>"
    haml :resource, layout_engine: :erb
  end
end

post "/post/?" do
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

  repo = "libreim/blog"
  base = "gh-pages"
  head = "new-post-#{filename}"

  begin
    raise "El título no debe estar vacío" if title.empty?
    raise "El autor no debe estar vacío" if author.empty?

    modify_repo repo, head, "Nuevo post: #{title}" do
      File.open("_posts/#{date}-#{filename}.md", "w") do |f|
        f.write <<EOF
---
layout: post
title: #{title}
authors: #{author.split /,\s*/}
category: #{category}
---

#{content}
EOF
    end
  end

    # Finally, create a pull request using octokit
    response = github.create_pull_request(repo, base, head, "Nuevo post: #{title}", "Añade *#{title}* de #{author}.")

    @message = "Tu post se ha enviado. <a href=\"#{response.html_url}\">Ver pull request</a>"
    haml :post, layout_engine: :erb
  rescue StandardError => e
    @error = "Algo ocurrió: <em>#{e}</em>"
    @prev_post = content
    haml :post, layout_engine: :erb
  end
end

post "/preview/?" do
  Kramdown::Document.new(params[:content], syntax_highlighter: :rouge).to_html
end
