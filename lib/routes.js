// Generated by CoffeeScript 1.4.0
(function() {
  var DOMAIN, RDIO_CONSUMER, RDIO_SECRET, Rdio, pages, routes, _ref;

  Rdio = require('node-rdio');

  pages = require('./pages');

  _ref = require('./globals'), RDIO_CONSUMER = _ref.RDIO_CONSUMER, RDIO_SECRET = _ref.RDIO_SECRET, DOMAIN = _ref.DOMAIN;

  module.exports = routes = function(robot) {
    return {
      home: function(req, res) {
        res.writeHead(200, {
          'Content-Type': 'text/html'
        });
        return res.end(pages.home({
          title: 'Pataku?'
        }));
      },
      auth: function(req, res) {
        var rdio, requestSecret, requestToken, verifier;
        res.writeHead(200, {
          'Content-Type': 'text/html'
        });
        requestToken = req.query['oauth_token'];
        requestSecret = robot.brain.get("RdioRequestSecret-" + requestToken);
        verifier = req.query['oauth_verifier'];
        if (!(requestToken && requestSecret && verifier)) {
          return res.end(pages.error({
            message: 'Error: Invalid request token'
          }));
        }
        rdio = new Rdio([RDIO_CONSUMER, RDIO_SECRET], [requestToken, requestSecret]);
        return rdio.completeAuthentication(verifier, function(error) {
          var accessSecret, accessToken, oldAccessToken;
          if (error) {
            robot.logger.debug(error);
            return msg.send("Error: " + error);
          }
          oldAccessToken = robot.brain.get('RdioAccessToken');
          accessToken = rdio.token[0];
          accessSecret = rdio.token[1];
          robot.brain.remove('RdioRequestToken').remove("RdioRequestSecret-" + requestToken).remove('RdioAccessToken').remove("RdioAccessSecret-" + oldAccessToken).set('RdioAccessToken', accessToken).set("RdioAccessSecret-" + accessToken, accessSecret).save();
          return res.end(pages.redirect({
            message: "Yay! Your access token is " + accessToken,
            redirect: '/'
          }));
        });
      },
      player: function(req, res) {
        var accessSecret, accessToken, rdio;
        res.writeHead(200, {
          'Content-Type': 'text/html'
        });
        accessToken = robot.brain.get('RdioAccessSecret');
        accessSecret = robot.brain.get("RdioAccessSecret-" + accessToken);
        if (!(accessToken && accessSecret)) {
          return res.end(pages.redirect({
            message: 'Please authorize rdio first.',
            redirect: '/'
          }));
        }
        rdio = new Rdio([RDIO_CONSUMER, RDIO_SECRET], [accessToken, accessSecret]);
        return rdio.call('currentUser', function(error) {
          if (error) {
            return res.end(pages.redirect({
              message: 'Please authorize rdio first.',
              redirect: '/'
            }));
          } else {
            return rdio.call('getPlaybackToken', {
              domain: DOMAIN
            }, function(error, data) {
              if (error) {
                return res.end(pages.error({
                  message: "Error: " + error
                }));
              } else {
                return res.end(pages.player({
                  playbackToken: data
                }));
              }
            });
          }
        });
      }
    };
  };

}).call(this);