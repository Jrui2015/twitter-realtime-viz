/* jshint esversion:6 */
let MongoClient = require('mongodb').MongoClient;
let url = require('./config/db').url;
let assert = require('assert');
let Stream = require('node-tweet-stream');
let followToken = require('./config/follow');

MongoClient.connect(url, (err, db) => {
  assert.equal(null, err);
  var collection = db.collection('users');
  collection.find({}).toArray((err, docs) => {
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

      var t = {
        _id: json.id_str,
        created_at: json.created_at,
        text: json.text,
        source: json.source,
        coordinates: json.coordinates,
        place: json.place,
        retweet_count: json.retweet_count,
        favorite_count: json.favorite_count,
        entities: json.entities,
        user: {
          _id: json.user.id_str,
          created_at: json.user.created_at,
          name: json.user.name,
          screen_name: json.user.screen_name,
          location: json.user.location,
          description: json.user.description,
          followers_count: json.user.followers_count,
          friends_count: json.user.friends_count,
          listed_count: json.user.listed_count,
          favourites_count: json.user.favorites_count,
          statuses_count: json.user.statuses_count,
          time_zone: json.user.time_zone,
          lang: json.user.lang
        }
      };

      tweets.save(t, (err, result) => {
        console.log(`save tweet '${json.text}'`);
        db.close();
      });

    });

  });


  follower.on('error', (err) => {
    console.log(err);
    follower.destory();
  });

  follower.follow(users);
}
