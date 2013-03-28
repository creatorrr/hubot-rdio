// Generated by CoffeeScript 1.4.0
(function() {
  var compile, pages;

  compile = require('coffeecup').compile;

  module.exports = pages = {
    home: compile(function() {
      doctype(5);
      return html(function() {
        return body(function() {
          h1(this.title);
          div('#gaga', function() {
            return '';
          });
          script({
            src: '/socket.io/socket.io.js'
          });
          script({
            src: '/jquery.js'
          });
          script({
            src: '/jquery.rdio.js'
          });
          return coffeescript(function() {
            return $(function() {
              var socket;
              socket = io.connect();
              return socket.on('gaga', function(data) {
                return console.log(data);
              });
            });
          });
        });
      });
    }),
    error: compile(function() {
      return body(function() {
        return p(this.message);
      });
    })
  };

}).call(this);