---
title: Machinist and Paperclip
permalink: 2009/07/25/machinist-and-paperclip
published_at: 2009-07-25 03:55:00 +0000
---

Once you've found a comfortable fixture replacement for your tests, there is no going back. For many, that's something like [Factory Girl](http://thoughtbot.com/projects/factory_girl). For me, it is Pete Yandell's [Machinist](http://github.com/notahat/machinist). So when I wanted to write some [Cucumber](http://cukes.info/) scenarios for a model using [Paperclip](http://thoughtbot.com/projects/paperclip) for file attachments, I definitely needed a factory for creating it!

In Machinist, building factories (called _blueprints_) is easy for standard ActiveRecord attributes and associations. Check out the [comprehensive README](http://github.com/notahat/machinist) in the repository. Here is the start of a `blueprints.rb` file:

```
require 'faker'

Sham.title { Faker::Lorem.sentence }

AttachedDocument.blueprint do
  title
end
```

As it turns out, it is equally easy to add support for models using Paperclip. Say our model looks like this:

```
class AttachedDocument < ActiveRecord::Base
  has_attached_file :document
end
```

Then your blueprint should incorporate the attached file like this:

```
require 'faker'

Sham.title { Faker::Lorem.sentence }
Sham.document { Tempfile.new('the attached document') }

AttachedDocument.blueprint do
  title
  document
end
```

Using a [Tempfile](http://ruby-doc.org/stdlib/libdoc/tempfile/rdoc/index.html) instance to represent the paperclip attachments works without a hitch, and the implementation of Tempfile will ensure there are no file duplicates. It will also mean that the other methods that paperclip sets up (such as `document_file_name`, `document_content_type` and `document_file_size`) are all accessible on the generated object. Now get going and test!

