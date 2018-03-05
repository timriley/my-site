---
title: Beijing Olympic medal tally for our Campfire bot
permalink: 2008/08/10/beijing-olympic-medal-tally-for-our-campfire-bot
published_at: 2008-08-10 08:00:00 +0000
---

I've recently been working on a bot framework for 37signals' [Campfire](http://campfirenow.com/) web chat system. We use Campfire at work and it's been great for having fun together and increasing team cohesiveness.

Having a bot in the room is also good for random quotes, Chuck Norris facts and comic strips. We also plan to add a few useful work-related things, such as git & subversion commit messages and server monitoring alerts.

The bot is plugin-oriented and easy to extend. Check out the [code on github](http://github.com/timriley/campfire-bot/tree/master). It's still in flux and I would love to hear any feedback.

This afternoon I hacked together a little plugin to report the Beijing olympics medal tally, thanks to an idea of Sean's. The code is highly specific, but it shows how easy (and fun!) it is to add a command to the bot and scrape data off the web using hpricot.

Here it is:

```
require 'open-uri'
require 'hpricot'

class BeijingTally < PluginBase

  on_command 'tally', :tally

  def tally(msg)
    output = "#{'Pos.'.rjust(6)} - #{'Country'.ljust(25)} - G - S - B - Total\n"
    rows = ((Hpricot(open('http://results.beijing2008.cn/WRM/ENG/INF/GL/95A/GL0000000.shtml'))/'//table')[1]/'tr')[2..-1]
    rows.each_with_index do |row, i|
      cells = row/'td'
      output += "#{strip_tags_or_zero(cells[0].inner_html).rjust(6)} - " # position
      output += "#{((i == rows.length - 1) ? '' : strip_tags_or_zero(cells[1].inner_html)).ljust(25)} - " # country
      output += "#{strip_tags_or_zero(cells[-5].inner_html).rjust(3)} - " # gold
      output += "#{strip_tags_or_zero(cells[-4].inner_html).rjust(3)} - " # silver
      output += "#{strip_tags_or_zero(cells[-3].inner_html).rjust(3)} - " # bronze
      output += "#{strip_tags_or_zero(cells[-2].inner_html).rjust(3)}\n" # total
    end

    paste(output)
  end

  private

  # Take away the HTML tags from the string and insert a '0' if it is empty
  def strip_tags_or_zero(str)
    (out = str.gsub(/<\/?[^>]*>/, "").strip).blank? ? '0' : out
  end
end
```
