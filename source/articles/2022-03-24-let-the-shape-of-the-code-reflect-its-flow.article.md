---
title: Let the shape of the code reflect its flow
permalink: 2022/03/24/let-the-shape-of-the-code-reflect-its-flow
published_at: 2022-03-24 22:50 +1100
---

Say you’re building a system for handling messages off some kind of queue. For each message, you need to run a series of steps: first to decode the message, next to wrap it in some common structure, and finally, to process the message based some logic provided by the users of your system.

Let’s imagine the queue subscription as provided: we’ll have a `subscriber` object that yields a `message` to us via a `#handle` method:

```ruby
subscriber.handle do |message|
  # Here's where we need to hook our logic
end
```

For each of processing steps, let’s also imagine we have corresponding private methods in our class:

1. `#decode(message)`
2. `#build_event(decoded_message)` — with an “event” being that common structure I mentioned above
3. `#process(event)`

With these set up, we could wire them all together in our handler block like so:

```ruby
subscriber.handle do |message|
  process(build_event(decode(message)))
end
```

This is hard to grok, however. There's a lot going on in that one line, and most critically, you have to read it inside out in order to understand its flow: start with `decode`, then work backwards to `build_event` and then `process`.

Instead, we should strive to **let the shape of our code reflect its flow.** We want to make it easy for the reader of the code to quickly understand the flow of logic even with just a glance.

One step in this direction could be to use intermediate variables to hold the results of each step:

```ruby
subscriber.handle do |message|
  decoded_message = decode(message)
  event = build_event(decoded_message)
  process(event)
end
```

This isn’t bad, but the variable names at the beginning of the line add extra noise, and they push back the most meaningful part of each step — the private method names — into a less prominent location.

What I would recommend here is that we take advantave of Ruby’s `Object#then` to turn this into something that actually _looks_ like a pipeline, since that’s the flow that we’re actually creating via these methods: the steps run in sequence, and the output of one step feeds into the next.

```ruby
subscriber.handle do |message|
  message
    .then { |message| decode(message) }
    .then { |decoded| build_event(decoded) }
    .then { |event| process(event) }
end
```

This makes it much clearer that this is a pipeline of three distinct steps, with `message` as its starting point. Through the shape of those blocks, and the pipe separators distinguishing the block argument from the block body, it also brings greater prominence to the name of the method that we’re calling for each step.

Most importantly, we’ve made this code much more _scannable_. We’re giving the eye of the reader hooks to latch onto, via the repeated "thens" stacked on top of each other, in addition to their corresponding blocks. The shape of the code embodies its flow, and in doing so, we’ve created a table-of-contents-like structure that both summarises the behaviour, and can serve as a jumping off point for further exploration if required.

To further reduce noise here, we could try Ruby’s new numbered implicit block arguments:

```ruby
subscriber.handle do |message|
  message
    .then { decode(_1) }
    .then { build_event(_1) }
    .then { process(_1) }
end
```

However, I’d consider this a step too far, since it takes away what is otherwise a helpful signal, with the block argument name previously serving as a hint to the type of value that we’re dealing with at each point in the pipeline.

By taking the time to consider the flow of our logic, and finding a way for the shape of code to embody that flow, we’ve made our code easier to understand, easier to maintain, and — why not say it? — _truer to itself._ This is a method I’d walk away from feeling very satisfied having written. Salubrious!
