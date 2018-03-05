---
title: A Cycle Helper for Sinatra
permalink: 2009/02/13/a-cycle-helper-for-sinatra
published_at: 2009-02-12 22:20:00 +0000
---

[Sinatra's](http://sinatrarb.com/) minimalist tack encourages you to build just the number of helpers that is required for your app. In doing so, it's also a chance to improve your Ruby fu. While the source for the helpers that come with Rails provides an excellent starting point for your particular subset, they're often built to keep all comers happy. You can do something a lot slimmer for your narrowly focused Sinatra app.

[![](squarespace/images/ss/2e7cfa9d7295.jpg)](http://www.flickr.com/photos/ickypoo/510063218/)

Here's [what I came up with](http://github.com/timriley/unfuddle-helpdesk/blob/46ed4c40f7a217a3bd465c9f7783f065e4462d01/unfuddle_helpdesk.rb#L43) for a cycle helper to alternately colour table rows via cycling their CSS classes:

**Uppublished_at:** check the end of this post for some improved solutions!

```
helpers do
  def cycle
    @_cycle ||= reset_cycle
    @_cycle = [@_cycle.pop] + @_cycle
    @_cycle.first
  end

  def reset_cycle
    @_cycle = %w(even odd)
  end
end
```

For reference, [this is the source](http://github.com/rails/rails/blob/ff3fb6c5f3b2a0592189545f6f24ef759df6a12e/actionpack/lib/action_view/helpers/text_helper.rb#L379) for Rails' equivalent set of helpers, comprising about one hundred or so lines of code. Now, here are my [helpers in use](http://github.com/timriley/unfuddle-helpdesk/blob/46ed4c40f7a217a3bd465c9f7783f065e4462d01/views/ticket_report.haml#L35):

```
%table.tickets{:cellpadding => 0, :cellspacing => 0}
  %thead
    %tr
      %th No.
      %th Summary
      %th Reporter
      %th Assignee
      %th Updated
  %tbody
    - reset_cycle
    - group.tickets.each do |ticket|
      %tr{:class => "#{ticket.out_of_bounds? ? 'out-of-bounds' : 'unassigned'} #{cycle}"}
        = partial('ticket_row', :locals => {:ticket => ticket})
```

Nothing like writing your own helpers for a nice sense of achievement! And now a question for you? Can you think of a neater way to cycle through a series of strings? Would love to hear your feedback.

**Uppublished_at:** Oceanic Ruby guru [Lachie Cox](http://smartbomb.com.au/) has forked my helpers and provided some smarter versions. Thanks Lachie!

```
helpers do
  def cycle
    %w{even odd}[@_cycle = ((@_cycle || -1) + 1) % 2]
  end

  CYCLE = %w{even odd}
  def cycle_fully_sick
    CYCLE[@_cycle = ((@_cycle || -1) + 1) % 2]
  end
end
```
