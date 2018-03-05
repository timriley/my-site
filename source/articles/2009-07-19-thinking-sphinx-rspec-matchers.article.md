---
title: Thinking Sphinx RSpec Matchers
permalink: 2009/07/19/thinking-sphinx-rspec-matchers
published_at: 2009-07-18 23:40:00 +0000
---

How do you use [RSpec](http://rspec.info/) to drive the design of your models that will use [Thinking Sphinx](http://ts.freelancing-gods.com/) for search? Say you're already using [Cucumber](http://cukes.info/) for integration tests to verify your index builds correctly and searches return the results you expect. For your models' specs, you'll want something that is lighter but doesn't sacrifice your overall test coverage.

To achieve this, I wrote a couple of small RSpec matchers that inspect the Thinking Sphinx index object on your model to ensure that it contains the fields and attributes that you expect.

```
Spec::Matchers.define(:index) do |*field_names|
  description do
    "have a search index for #{field_names.join('.')}"
  end
  match do |model|
    all_fields = field_names.dup
    first_field = all_fields.pop

    model.sphinx_indexes.first.fields.select { |field|
      field.columns.length == 1 &&
        field.columns.first.__stack == all_fields.map { |s| s.to_sym } &&
        field.columns.first.__name == first_field.to_sym
    }.length == 1
  end
end

Spec::Matchers.define(:have_attribute) do |*attr_names|
  description do
    "have a search attribute for #{attr_names.join('.')}"
  end
  match do |model|
    all_attrs = attr_names.dup
    first_attr = all_attrs.pop

    model.sphinx_indexes.first.attributes.select { |attr|
      attr.columns.length == 1 &&
        attr.columns.first.__stack == all_attrs.map { |s| s.to_sym } &&
        attr.columns.first.__name == first_attr.to_sym
    }.length == 1
  end
end
```

Put these matchers in your `spec_helper.rb` or somewhere else handy, and then you can use them in your model specs:

```
describe Question do
  it { should index(:topic) }
  it { should have_attribute(:state) }
end
```

They read quite nicely in the single-line format above, and the matchers provide a readable description when you run the spec:

```
Question
- should have a search index for topic
- should have a search attribute for legacy_mastery
```

While these matchers work well for me, I feel that @sphinx\_indexes@ is perhaps an object I should leave alone, and not something I can rely on having continued access to. Please leave a comment if you have any suggestions for doing this more cleanly!

What I did learn, however, is how simple it was to write custom matchers for RSpec. If you haven't tried it before, I strongly suggest you give it a go! RSpec's matcher DSL is straightforward, and the documentation has [everything you need](http://rspec.rubyforge.org/rspec/1.2.8/classes/Spec/Matchers.html) to get started.

