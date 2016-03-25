#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key,
  config.consumer_secret,
  config.access_token,
  config.access_token_secret = File.readlines('config').map(&:strip)
end

client.sample do |obj|
  puts obj.text if obj.is_a? Twitter::Tweet
end
