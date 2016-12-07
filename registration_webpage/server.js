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
var slack_token_location = "/opt/chat-ops-common/slack-token.json"
var oauth_token_location = "/opt/chat-ops-common/c66-token.json"


app.use(express.static(path.join(__dirname , 'app/view/css')));
app.use(express.static(path.join(__dirname , 'app/view/html')));

app.set('view engine', 'ejs');
app.engine('html', require('ejs').renderFile);
app.set('views', path.join(__dirname, 'app/view/html'))

app.use(session({ secret: 'keyboard cat' }))
app.use(flash());

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use('/register', register);



app.get('/', function(req, res) {
  fs.readFile(oauth_token_location, 'utf8', function (err,data) {
    if (err){
      res.render(__dirname + '/app/view/html/register.html', { expressFlash: req.flash('success')});
    }
    else{
      fs.readFile(slack_token_location, 'utf8', function (err,data) {
        if (err) res.render(__dirname + '/app/view/html/register.html', {info: req.flash("info")});
        else res.sendfile(__dirname + '/app/view/html/success.html');
      });
    }
  });
});

app.listen(PORT);
console.log('Running on http://localhost' + PORT);
