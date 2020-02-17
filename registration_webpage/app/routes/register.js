const credentials = {
  client: {
    id: "<your c66 application id>",
    secret: "<your c66 application secret>"
  },
  auth: {
    tokenHost: 'https://app.cloud66.com/oauth/authorize'
  }
};

var token = null
var slack_token_location = "/opt/chat-ops-common/slack-token.json"
var oauth_token_location = "/opt/chat-ops-common/c66-token.json"

var flash = require('connect-flash');
var express = require('express');
var open = require('open');
var request = require('request');
var oauth2 = require('simple-oauth2').create(credentials);
var router = express.Router();
var fs = require('fs');
var path = require('path');



const authorizationUri = oauth2.authorizationCode.authorizeURL({
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  scope: 'public admin redeploy jobs users',
});



router.post('/', function(req, res){
  var tokenConfig = {
    code: req.body.c66Token,
    redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
  };

  oauth2.authorizationCode.getToken(tokenConfig, (error, result) => {
    if (error){
      req.flash('success', 'Invalid cloud 66 token');
      res.redirect('/');
    }
    else{
      token = oauth2.accessToken.create(result);
      if(req.body.slackToken != "" && req.body.c66Token != ""){
          fs.writeFile(slack_token_location, "{\"slack_token\":\""+req.body.slackToken+"\"}", function(err) {
              if(err) {
                console.log(err);
                res.sendFile(path.resolve('app/view/html/failure.html'), {errors : req.flash('info')});
              }else{
                fs.writeFile(oauth_token_location, "{\"local_token\":\""+token.token.access_token+"\"}", function(err) {
                    if(err) {
                      console.log(err);
                      res.sendFile(path.resolve('app/view/html/failure.html'));
                    }
                    else{
                     res.redirect('/')
                    }
                });
              }
          });
      }else res.redirect('/');
    }
  });
});


router.post('/oauth', function(req, res){
  res.redirect(authorizationUri);
});

router.post('/deregister', function(req, res){
   fs.stat(slack_token_location, function (err, stats) {
      if (err) res.sendFile(path.resolve('app/view/html/failure.html'));
      fs.unlink(slack_token_location,function(err){
          if(err) res.sendFile(path.resolve('app/view/html/failure.html'));
          fs.stat(oauth_token_location, function (err, stats) {
             if (err) res.sendFile(path.resolve('app/view/html/failure.html'));
             fs.unlink(oauth_token_location,function(err){
                 if(err) res.sendFile(path.resolve('app/view/html/failure.html'));
                    req.flash('success', 'You have successfully unregistered Igor');
                    res.redirect('/');
             });
          });
       });
    });
 });

module.exports = router;
