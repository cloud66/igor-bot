var express = require('express');
var bodyParser = require('body-parser');
var register = require('./app/routes/register.js');
var fs = require('fs');
var flash = require('connect-flash');
var session = require('express-session');
var path = require ('path');
var app = express();

const PORT = 8080;

var path = require('path');

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use(flash());
app.use(session({ secret: 'keyboard cat' }))

app.engine('.html', require('ejs').__express);
app.set('view engine', 'html');

app.use('/register', register);
app.use(express.static(path.join(__dirname + '/app/view/css')));
app.use(express.static(path.join(__dirname + '/app/view/html')));

app.get('/', function(req, res) {
  fs.readFile('/opt/chat-ops-common/c66-token.json', 'utf8', function (err,data) {
    if (err){
      res.render(__dirname + '/app/view/html/register.html', {info: req.flash("info")});
      //res.sendFile(__dirname + '/app/view/html/register.html');
    }
    else{
      fs.readFile('/opt/chat-ops-common/slack-token.json', 'utf8', function (err,data) {
        if (err) res.render(__dirname + '/app/view/html/register.html', {info: req.flash("info")});
        else res.sendfile(__dirname + '/app/view/html/success.html');
      });
    }
  });
});

app.listen(PORT);
console.log('Running on http://localhost' + PORT);
