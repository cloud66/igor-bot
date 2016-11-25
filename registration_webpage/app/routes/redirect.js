var express = require('express');
var router = express.Router();

router.get('/register', function(req, res) {
    res.sendfile('./app/view/html/register.html');
});

router.get('/success', function(req, res) {
    res.sendfile('./app/view/html/success.html');
});

router.get('/failure', function(req, res) {
    res.sendfile('./app/view/html/failure.html');
});



module.exports = router;
