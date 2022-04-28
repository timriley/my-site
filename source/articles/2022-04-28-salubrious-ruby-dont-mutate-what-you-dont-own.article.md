---
title: "Salubrious Ruby: Don’t mutate what you don’t own"
permalink: 2022/04/28/salubrious-ruby-dont-mutate-what-you-dont-own
published_at: 2022-04-28 23:00 +1000
---

When we’re writing a method in Ruby and receiving objects as arguments, a helpful principle to follow is “don’t mutate what you don’t own.”

Why is this? Those arguments come from places that we as the method authors can’t know, and a well-behaved method shouldn’t alter the external environment unexpectedly.

Consider the following method, which takes an array of numbers and appends a new, incremented number:

```ruby
def append_number(arr)
  last_number = arr.last || 0
  arr << last_num + 1
end
```

If we pass in an array, we’ll get a new number appended in the returned array:

```ruby
my_arr = [1, 2]
my_new_arr = append_number(my_arr) # => [1, 2, 3]
```

But we’ll also quickly discover that this has been achieved by mutating our original array:

```ruby
my_arr = [1, 2]
my_new_arr = append_number(arr) # => [1, 2, 3]
my_arr # => [1, 2, 3]
```

We can confirm by an object equality check that this is still the one same array:

```ruby
my_new_arr.eql?(my_arr) # => true
```

This behavior is courtesy of Ruby’s `Array#<<` method (aka `#append` or `#push`), which appends the given object to the receiver (that is, `self`), before then returning that same self. This kind of self-mutating behaviour is common across both the `Array` and `Hash` classes, and while it can provide some conveniences in local use (such as a chain of `#<<` calls to append multiple items to the same array), it can lead to surprising results when that array or hash comes from anywhere *non*-local.

Imagine our example above is part of a much larger application. In this case, `my_arr` will most likely come from somewhere far removed and well outside the purview of `append_number` or whatever class contains it. As the authors of `append_number`, we have no idea how that original array might otherwise be used! For this reason, the courteous approach to take is not to mutate the array, but instead create and return a new copy:

```ruby
def append_number(arr)
  last_number = arr.last || 0

  # There are many ways we can achieve the copy; here's just one
  arr + [last_number]
end
```

This way, the caller of our method can trust their original values to go unchanged, which is what they would likely expect, especially if our method doesn’t give any hint that it will mutate.

```ruby
my_arr = [1, 2]
my_new_arr = append_number(arr) # => [1, 2, 3]
my_arr # => [1, 2]
```

This is a very simple example, but the same princple applies for all kinds of mutable objects passed to your methods.

A more telling story here comes from earlier days of Ruby, around how we handled options hashes passed to methods. We used to do things like this:

```ruby
def my_method(options = {})
  some_opt = options.delete(:some_opt)
  # Do something with some_opt...
end

my_method(some_opt: "some value")
```

Using trailing options hashes like this was how we provided “keyword arguments” before Ruby had them as a language feature. Now the trouble with the method above is that we’re mutating that `options` hash by deleting the `:some_opt` key. So if the user of our method had code like this:

```ruby
common_options = {some_opt: "some value"}

first_result = my_method(common_options)
second_result = my_method(common_options)
```

We’d find ourselves in trouble by the time we call `my_method` the second time, because at that point the `common_options` hash will no longer have `some_opt:`, since the first invocation of `my_method` deleted it — oops!

This is a great illustration of why modern Ruby’s keyword arguments work the way they do. When we accept a splatted keyword hash argument like `**options`, Ruby ensures it comes into the method as a new hash, which means that operations like `options.delete(:some_opt)` do in fact become local in scope, and therefore safe to use.

So now that we’ve covered both arrays and hashes now as Ruby’s most common “container” objects, what about the other kinds of application-specific structures that we might encounter in real world codebases? Objects representing domain models of various kinds, an instance of an `ActiveRecord::Base` subclass, even? Even in those cases, this principle still holds true. Our code is easier to understand and test when we can reduce the number of dimenstions to its behaviour, and mutating passed-in objects is a big factor in this, especially if you think about methods calling other methods and so on. There are ways we can design our applications to make this a natural approach to take, even for rich domain objects, but that is a topic for another day!

Until then, hopefully this walkthrough here can serve as a reminder to keep our methods courteous, to respect mutable values provided from outside, and wherever possible, leave them undisturbed and unmutated. [Salubrious!](/writing/2022/03/24/salubrious-ruby/)

**Bonus content!** In preparing this post, I thought about whether it might be helpful to note that Ruby is a “pass by reference” language, since that’s the key underlying behavior that can result in these accidental mutations. However, my intuition here was actually back to front! Thanks to this [wonderful stackoverflow answer](https://stackoverflow.com/a/22827949), I was reminded that Ruby is in fact a “pass by value” language, but that all values are references.
