# frozen_string_literal: true
require 'dotenv'
require 'sinatra'
require 'active_record'
require 'sqlite3'
require 'pry'
require 'pry-byebug'
require 'aws-sdk'
require 'mail'
require 'fileutils'

Dotenv.load!

require_relative './aws'
require_relative './db'
require_relative './error'
require_relative './video'
require_relative './sns_processor'

# ~/ngrok http --hostname shiyason.ap.ngrok.io -region ap 80

set :bind, '0.0.0.0'
set :port, 80

post '/' do
  SnsProcessor.new(request).process!
end