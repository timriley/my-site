---
title: "Salubrious Ruby: Don’t mutate what you don’t own"
permalink: 2022/04/25/salubrious-ruby-dont-mutate-what-you-dont-own
published_at: 2022-04-25 22:50 +1100
---

When we’re writing a method in Ruby, and receiving objects from some place we cannot be aware of, a helpful principle to follow is “don’t mutate what you don’t own.”

Consider the following method, which takes an array of numbers, and appends a new incremented number:

```ruby
def append_number(arr)
  last_number = arr.last || 0
  arr << last_num + 1
end
```

If we pass it an array, we’ll get a new number appended in the returned array:

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

Imagine our example above is part of a much larger application. In this case, `my_arr` will most likely come from somewhere far removed and well outside the purview of `append_number` or whatever class contains it. As the authors of `append_number`, we have no idea what that original array might be onto be used for! For this reason, the courteous default approach to take is not to mutate the array, but return a new copy:

```ruby
def append_number(arr)
  last_number = arr.last || 0

  # There are many ways we can achieve the copy; here's just one
  arr + [last_number]
end
```

This way, blah blah caller can trust their original values to go unchanged

```ruby
my_arr = [1, 2]
my_new_arr = append_number(arr) # => [1, 2, 3]
my_arr # => [1, 2]
```

This is a very simple example, but the same princple applies for all kinds of mutable objects passed to your methods. (TODO: maybe a good hook here for the "pass by reference blah?")

Another relevant example is in dealing with options hashes. This has largely been resolved thanks to Ruby’s improved keyword argument handling lately, but blah blah

```ruby
def my_method(options = {})
  some_opt = options.delete(:some_opt)
  # do something with some_opt
end

common_options = {some_opt: "some value"}

first_result = my_method(common_options)
second_result = my_method(common_options) # some_opt will no longer be here!
```

If there's value in mutating, consider providing a `!`-suffixed alternative like Ruby’s core classes offer for some of their methods.











my_arr = [1, 2]

added_arr = add_a_number(my_arr) #


```

A general principle I like to follow when building systems in Ruby is “don’t mutate what you don’t own.” This has applications big and small, but as a starting point




- arrays and hashes mutable by default, but don't!
- ruby is "pass by reference" for these kinds of objects - which has its advantages, but can also cause problems if you're not careful
  - https://dev.to/jeremy/pass-by-reference-pass-by-value-c9e
  - https://stackoverflow.com/a/10974116/308563
  - "It's pass-by-value, but all the values are references." (https://stackoverflow.com/a/22827949/308563)
- consider "!" equivalents for methods that mutate
- consider **splats instead of options hashes, since that will give you a new hash
- yes, this breaks down entirely when it comes to activerecord instances, but that's a (much larger) topic for another day
