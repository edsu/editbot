editbot tweets edits to wikipedia articles linked from a particular page.
editbot needs you to put a few things in a config file to start working. You 
need to [register an app](https://app.twitter.com) at Twitter, and note down 
your auth keys. You need to set these:

* page: a URL of a page that contains links to Wikipedia articles you want to monitor
* refresh: number of seconds to wait before looking for new pages to monitor 

For example:

```json
{
  "nick": "editbot",
  "consumer_key": "aabbcccckkckck",
  "consumer_secret": "slksjdslkjsdfk",
  "access_token": "slkdfjlskdjfs",
  "access_token_secret": "lksdjflskjdf",
  "page": "https://en.wikipedia.org/wiki/Wikipedia:Meetup/ArtAndFeminism/Tasks",
  "refresh": 3600
}
```

## Install

    git clone http://github.com/edsu/editbot
    cd editbot
    npm install
    cp config.json.template config.json # and edit 
    coffee editbot.coffee

