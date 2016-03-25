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

class Twitter::Tweet
  def to_s
    s = ''
    s += '----------'
    s += "\n#{self.created_at}\n"
    s += "#{self.user.name}: #{self.text[0...10]}... (#{self.retweet_count})\n"
    unless self.retweeted_tweet.nil?
      s += "retweeted from: #{self.retweeted_tweet.text[0...10]} (#{self.retweeted_tweet.retweet_count} retweets)\n"
    end
    s += "quote: #{self.quoted_tweet.text[0...10]}...(#{self.quoted_tweet.retweet_count})\n" if self.quote?
    s += "hashtags: #{self.hashtags.map(&:text)}\n" unless self.hashtags.empty?
    s += "geo: #{self.geo.coordinates}\n" unless (self.geo.nil? or self.geo.coordinates.empty?)
    s += '----------'
  end
end

client.filter(locations: '-74,40,-73,41') do |obj|
  next unless obj.is_a?(Twitter::Tweet)
  puts obj
  binding.pry unless obj.retweeted_tweet.nil?
  binding.pry if obj.quote?
end
