#!/usr/bin/env ruby
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

  haml :index
end
