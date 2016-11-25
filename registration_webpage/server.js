var express = require('express');
var bodyParser = require('body-parser');
var redirect = require('./app/routes/redirect.js');
var register = require('./app/routes/register.js');
var file = require('./app/routes/test_file_existance.js');
var fs = require('fs');
var app = express();

const PORT = 8080;

var path = require('path');

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use('/redirect', redirect);
app.use('/register', register);
app.use('/file', file);

app.get('/', function(req, res) {
  fs.readFile('app/mock/one.txt', 'utf8', function (err,data) {
    if (err) res.sendFile(__dirname + '/app/view/html/register.html');
    else{
      fs.readFile('app/mock/two.txt', 'utf8', function (err,data) {
        if (err) res.sendFile(__dirname + '/app/view/html/register.html');
        else res.sendfile(__dirname + '/app/view/html/success.html')
      });
    }
  });
});

app.listen(PORT);
console.log('Running on http://localhost' + PORT);
