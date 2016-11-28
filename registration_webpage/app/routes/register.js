const credentials = {
  client: {
    id: "b5de172cffa26c681954c96adb55fd8d5d7c5298bcc7669e4969241fa92b413f",
    secret: "1d639bc0b2296aebdb7f0737645545ea2506ca8d20d0f9e34d976ba704debf23"
  },
  auth: {
    tokenHost: 'https://stage.cloud66.com/oauth/authorize'
  }
};

var express = require('express');
var open = require('open');
var request = require('request');
var oauth2 = require('simple-oauth2').create(credentials);
var router = express.Router();
var fs = require('fs');

const authorizationUri = oauth2.authorizationCode.authorizeURL({
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  scope: 'public admin redeploy jobs users',
});

router.post('/', function(req, res){
  if(req.body.slackToken != "" && req.body.c66Token != ""){
      fs.writeFile("/opt/chat-ops-common/slack-token.txt", req.body.slackToken, function(err) {
          if(err) return console.log(err);
      });
      fs.writeFile("/opt/chat-ops-common/c66-token.json", "{\"local_token\":\""+req.body.c66Token+"\"}", function(err) {
          if(err) return console.log(err);
      });

      fs.stat('/opt/chat-ops-common/is-token.txt', function (err, stats) {
          if (err) res.redirect('/')
          else{
              fs.unlink('/opt/chat-ops-common/is-token.txt',function(err){
                  if(err) res.redirect('/')
                  else res.redirect('/')
              });
          }
      });
  }else res.send(null);
});


router.post('/oauth', function(req, res){
  res.redirect(authorizationUri);
});

router.post('/deregister', function(req, res){
   fs.stat('/opt/chat-ops-common/slack-token.txt', function (err, stats) {
      if (err) res.sendfile(__dirname + '/app/view/html/failure.html');
      fs.unlink('/opt/chat-ops-common/slack-token.txt',function(err){
          if(err) res.sendfile(__dirname + '/app/view/html/failure.html');
          fs.stat('./server/upload/my.csv', function (err, stats) {
            if (err) res.sendfile(__dirname + '/app/view/html/failure.html');
            fs.unlink('/opt/chat-ops-common/c66-token.json',function(err){
               if(err) res.sendfile(__dirname + '/app/view/html/failure.html');
               fs.stat('/opt/chat-ops-common/is-token.txt', function (err, stats) {
                   if (err) res.sendfile(__dirname + '/app/view/html/failure.html');
                   fs.unlink('/opt/chat-ops-common/is-token.txt',function(err){
                      if(err) res.sendfile(__dirname + '/app/view/html/failure.html');
                      res.redirect('/')
               });
            });
         });
      });
    });
  });
});

module.exports = router;
