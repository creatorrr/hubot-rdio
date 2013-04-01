# Hubot-rdio

This is an external [hubot-script](https://github.com/github/hubot/blob/master/README.md#external-scripts) that provides an interface for connecting and playing [rdio](http://rd.io) songs using [hubot](http://hubot.gihub.com).

## Installing

1. Add `hubot-rdio` as a dependency to your hubot:
    `"hubot-rdio": "*"`
2. Tell hubot to load it. Add `"hubot-rdio"` to the `external-scripts.json` list in the hubot root folder.
3. `npm install` while you grab a beer.
4. Set the following environment variables and start hubot using `bin/hubot` :
 * `NODE_ENV:      'production'`
 * `RDIO_CONSUMER: '<your rdio consumer key>'`
 * `RDIO_SECRET:   '<your rdio consumer secret>'`


You can get the rdio consumer key and secret by creating an app at rdio's [developer page](http://developer.rdio.com/apps/mykeys).

## Commands

* `hubot init rdio` - Authenticate rdio.
* `hubot play (track|artist|album) <name>` - Search and play songs.
* `hubot play random` - Pick a random song off top charts and play it.
* `hubot pause` - Pause currently playing song.

## Contributing

Patches, bugs, ideas, love? Feel free to open issues or ping me at singh@diwank.name

## License

Copyright (c) 2013, Diwank Singh <singh@diwank.name>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
