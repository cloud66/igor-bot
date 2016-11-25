var express = require('express');
var router = express.Router();
var http = require('http');
var fs = require('fs');

router.get('/slack_token', function(req, res){
  // var options = {host: 'localhost', port: 8080, path: '/toto.html'};
  //
  // http.get(options, function(res) {
  // console.log("Got response: " + res.statusCode);
  // res.on("data", function(chunk) {
  //     console.log("BODY: " + chunk);
  //   });
  // }).on('error', function(e) {
  //   console.log("Got error: " + e.message);
  // });
});

module.exports = router;
