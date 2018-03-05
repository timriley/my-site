---
title: Accessing Basecamp's writeboards programatically with Ruby
permalink: 2009/01/08/accessing-basecamps-writeboards-programatically-with-ruby
published_at: 2009-01-08 13:25:00 +0000
---

[Basecamp's](http://basecamphq.com/) writeboards provide a great facility for versioned, collaborative document editing. However, any user of Basecamp will be able to tell you that they don't fit in as neatly as the other components of the system. Going to a writeboard takes you to an interim "loading" page before displaying the writeboard outside the regular interface of Basecamp.

To the developer, the difference between writeboards and the rest of Basecamp is highlighted further because writeboards are the only part of the app [without an API](http://developer.37signals.com/basecamp/). The enterprising Ruby developer, however, sees this as no barrier! So without further ado, I bring you [writeboard-rb](http://github.com/timriley/writeboard-rb/), a little Ruby class that allows you to access the contents of a writeboard programatically:

```
wb = Basecamp::Writeboard.new(
  :url => 'http://bigcorp.updatelog.com/W1234567',
  :username => 'user',
  :password => 'pass',
  :cookie_jar => '/tmp/foo',
  :use_ssl => true
)

puts wb.contents
```

Behind the scenes, no fewer than _five_ calls to the curl command line utility are made, along with a wee bit of Hpricot screen scraping to facilitate a form post otherwise made with JavaScript during the normal writeboard loading page. Using curl is necessary here because we need to preserve session cookies for _both_ the Basecamp and Writeboard domains during the process of fetching the writeboard's contents.

Anyway, please go [check out the code on github](http://github.com/timriley/writeboard-rb/), and feel free to fork it to make any improvements or extensions! I hope it can come in handy for you. It was a fun little challenge to take it this far.

