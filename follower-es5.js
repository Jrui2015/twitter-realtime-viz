var users_part = 1;

var MongoClient = require('mongodb').MongoClient;
var url = require('./config/db').url;
var apiConfig = require('./config/api-config');
var assert = require('assert');
var Stream = require('node-tweet-stream');
var followToken = require('./config/follow' + users_part);

// Setup stream
var follower = new Stream({
  consumer_key: followToken.consumer_key,
  consumer_secret: followToken.consumer_secret,
  token: followToken.access_token,
  token_secret: followToken.access_token_secret
});

var count = 0;
follower.on('tweet', function(tweet) {
  var brief = ++count + tweet.user.name + ': ' + tweet.text.substr(0,10) + '... ' +
        '\u2937 ' + tweet.retweet_count + '\u2665 ' + tweet.favorite_count;

  // TODO use web socket

  // stdout
  console.log(brief);

  MongoClient.connect(url, function(err, db) {
    assert.equal(null, err);
    db.collection('tweets').insert(tweet, function() { db.close(); });
  });
});

follower.on('error', function(err) {
  console.log(err);
});

function getRecentActiveUsers(db, callback) {
  var cursor = db.collection('users').find({
    // TODO use easy-date package
    updated_at: {$gte: new Date(new Date().getTime() - 24*60*60*1000)}
  });

  cursor
    .sort({updated_at: -1})
    .skip((users_part-1) * apiConfig.STREAM_USER_FOLLOW_LIMIT)
    .limit(apiConfig.STREAM_USER_FOLLOW_LIMIT)
    .toArray(callback);
}

function fetchActiveUsersAndFollows() {
  MongoClient.connect(url, function(err, db) {
    assert.equal(null, err);

    getRecentActiveUsers(db, function(err, docs) {
      console.log('totally ' + docs.length + ' users');

      var users = docs.map(function(d) {return d._id;});
      db.close();

      follower._filters.follow = {};
      follower.follow(users);
    });
  });

  setTimeout(fetchActiveUsersAndFollows, 2*60*1000);
}

// Let's start it
fetchActiveUsersAndFollows();
