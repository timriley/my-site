---
title: Rails Label Helpers with Blocks
permalink: 2010/03/30/rails-label-helpers-with-blocks
published_at: 2010-03-30 03:20:00 +0000
---

Whenever I work closely with designers, I try to learn a trick or two. From my latest project with the inimitable [Max Wheeler](http://makenosound.com/), one of the things I picked up was his preferred strategy for building forms: nesting the inputs along with the label text inside a label tag. Something like this:

```
<label>
  Name
  <input type="text" name="article[title]"/>
</label>
```

This structure behaves as you would expect. Clicking the "name" text on the page will focus the input element nested within the same label. The benefit is that you no longer have to worry about synchronising the input's DOM ID with the label's `for` attribute.

Doing this using the ActionView form helpers is not currently possible. Fortunately, it is easy to roll your own solution using a custom FormBuilder.

```
class SmartLabelFormBuilder < ActionView::Helpers::FormBuilder
  def label(method, content_or_options_with_block = nil, options = {}, &block)
    if !block_given?
      # No block, use the standard label helper.
      super(method, content_or_options_with_block, options)
    else
      # We've got a block. This is where we want to do our business.
      options = content_or_options_with_block.is_a?(Hash) ? content_or_options_with_block.stringify_keys : {}

      if errors_on?(method)
        (options['class'] = options['class'].to_s + ' error').strip!
      end

      @template.content_tag(:label, options, &block)
    end
  end

  private

  def errors_on?(method)
    @object.respond_to?(:errors) && @object.errors.respond_to?(:on) && @object.errors.on(method.to_sym)
  end
end

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  html_tag
end
```

Include the above somewhere in your app (perhaps a file in `lib/`) and now you can start building you forms like this:

```
<% form_for(@article, :builder => SmartLabelFormBuilder) do |form| %>
  <% form.label(:title) do %>
    Title
    <%= form.text_field(:title) %>
  <% end %>
<% end %>
```

_See [this gist](http://gist.github.com/348707) to fork or download these code examples._

The form builder will pass back to the regular `label` method if you're not using a block, so you can still create standalone labels if you need.

It also takes care of displaying form errors. If a label contains a field with an error, then the helper will give it and `error` class. Then you can use CSS selectors like `label.error` and `label.error input@`to change the appearance of your label text and inputs for these fields. For this to work nicely, I've overwritten ActionView's `field_error_proc` so that it does nothing by default to fields with errors.

Handling labels and inputs in this way is also totally fine for testing tools. Capybara, for example, uses [a bunch of different xpaths](http://github.com/jnicklas/capybara/blob/5661d67ae9458890ac458cb6bbb2ac45513fac2a/lib/capybara/xpath.rb#L139) to locate fields, including some that support labels with nested inputs. So a Cucumber step like this works exactly as you expect:

```
When I fill in "Title" with "Rails Label Helpers with Blocks"
```

You might also want to check out this [patch for rails 3](https://rails.lighthouseapp.com/projects/8994/tickets/3645-let-label-helpers-accept-blocks) that adds block support to labels. It's in need of a few testers and "+1" comments so that it can get incorporated!

