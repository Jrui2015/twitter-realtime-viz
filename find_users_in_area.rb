#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'twitter'
require 'mongo'
db = Mongo::Client.new(['localhost:27017'], database: 'realtime-twitter-viz')

bounding_boxes = {
  world: '-180,-90,180,90',
  nyc: '-74,40,-73,41',
}

area = ARGV[0].to_sym if ARGV[0]
area ||= :nyc

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key,
  config.consumer_secret,
  config.access_token,
  config.access_token_secret = File.readlines('config/locations.config').map(&:strip)
end

class Twitter::Tweet
  def to_brief
    "#{self.user.name}: #{self.text[0...10]}... (\u2937 #{self.retweet_count} \u2665 #{self.favorite_count})"
  end

  def to_s
    s = ''
    s += '----------'
    s += "\n#{self.created_at}\n"
    s += self.to_brief + "\n"
    unless self.retweeted_tweet.nil?
      s += "retweeted from: #{self.retweeted_tweet.to_brief}\n"
    end
    s += "quote: #{self.quoted_tweet.to_brief}\n" if self.quote?
    s += "hashtags: #{self.hashtags.map(&:text)}\n" unless self.hashtags.empty?
    s += "geo: #{self.geo.coordinates}\n" unless (self.geo.nil? or self.geo.coordinates.empty?)
    s += '----------'
  end
end

statistics_fname = "#{area}.log"
begin
  up_minutes,
  tweet_count,
  retweet_count,
  quote_count,
  hashtag_count,
  geo_count = File.readlines(statistics_fname).map(&:to_i)
rescue Errno::ENOENT => err
  puts"#{err}. Create new statistics log"
end

up_minutes ||= 0
tweet_count ||= 0
retweet_count ||= 0
quote_count ||= 0
hashtag_count ||= 0
geo_count ||= 0

user_ids = Set.new(db[:users].find())

work = lambda do |obj|
    next unless obj.is_a?(Twitter::Tweet)
    tweet_count += 1
    puts obj
    retweet_count += 1 unless obj.retweeted_tweet.nil?
    quote_count += 1 if obj.quote?
    hashtag_count += 1 unless obj.hashtags.empty?
    unless (obj.geo.nil? or obj.geo.coordinates.empty?)
      geo_count += 1
      id = obj.user.id
      unless user_ids.include?(id)
        user_ids.add(id)
        db[:users].insert_one({ _id: id })
        puts "inserting user id #{id}"
      end
    end
    puts "total: #{tweet_count}; retweet: #{retweet_count}; quote: #{quote_count}"
    puts "have_hashtags: #{hashtag_count}; have_geo: #{geo_count}"
end

start_time = Time.now
begin
  if area == :sample
    client.sample(&work)
  else
    client.filter(locations: bounding_boxes[area], &work)
  end
rescue Interrupt
  puts
  unless area == :sample
    elapse = (Time.now - start_time).to_i / 60
    File.write(statistics_fname, [up_minutes + elapse,
                                    tweet_count,
                                    retweet_count,
                                    quote_count,
                                    hashtag_count,
                                    geo_count].join("\n") + "\n")
  end
end
