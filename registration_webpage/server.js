var express = require('express');
var bodyParser = require('body-parser');
var register = require('./app/routes/register.js');
var fs = require('fs');
var app = express();

const PORT = 8080;

var path = require('path');

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use('/register', register);

app.get('/', function(req, res) {
  fs.readFile('/opt/chat-ops-common/c66-token.json', 'utf8', function (err,data) {
    if (err) {
      console.log('c66 token introuvable')
      res.sendFile(__dirname + '/app/view/html/register.html');
    }
    else{
      fs.readFile('opt/chat-ops-common/slack-token.txt', 'utf8', function (err,data) {
        if (err) {
          console.log('slack introuvable')
          res.sendFile(__dirname + '/app/view/html/register.html');
        }
        else res.sendfile(__dirname + '/app/view/html/success.html');
      });
    }
  });
});

app.listen(PORT);
console.log('Running on http://localhost' + PORT);
