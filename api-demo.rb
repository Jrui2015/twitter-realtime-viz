#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'twitter'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key,
  config.consumer_secret,
  config.access_token,
  config.access_token_secret = File.readlines('config').map(&:strip)
end

i = 0
objs = []
client.filter(locations: '-74,40,-73,41') do |obj|
  objs.push(obj)
  puts "#{obj.user.name}: #{obj.text}"
  i += 1
  break if obj.retweet_count > 0
end

o = objs[-1]
binding.pry
