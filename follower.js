/* jshint esversion:6 */
let MongoClient = require('mongodb').MongoClient;
let url = require('./config/db').url;
let assert = require('assert');
let Stream = require('node-tweet-stream');
let followToken = require('./config/follow');

MongoClient.connect(url, (err, db) => {
  assert.equal(null, err);
  var collection = db.collection('users');
  // TODO think a way to split users on separated streams
  collection.find({}).limit(5000).toArray((err, docs) => {
    console.log(`totally ${docs.length} users`);
    var users = docs.map((d) => {return d._id;}).join(',');
    startFollowing(users);
    db.close();
  });
});

function startFollowing(users) {

  let follower = new Stream({
    consumer_key: followToken.consumer_key,
    consumer_secret: followToken.consumer_secret,
    token: followToken.access_token,
    token_secret: followToken.access_token_secret
  });

  follower.on('tweet', (json) => {

    MongoClient.connect(url, (err, db) => {
      assert.equal(null, err);
      var tweets = db.collection('tweets');

      console.log(`${json.user.name}: ${json.text.substr(0,10)}... (\u2937 ${json.retweet_count} \u2665 ${json.favorite_count})`);

      // tweets.save(json, (err, result) => {
      //   db.close();
      // });

    });

  });


  follower.on('error', (err) => {
    console.log(err);
    follower.destory();
  });

  follower.follow(users);
}
