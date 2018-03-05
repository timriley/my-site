---
title: Mocking out your Rails helpers in helper specs
permalink: 2008/03/19/mocking-out-your-rails-helpers-in-helper-specs
published_at: 2008-03-19 10:35:00 +0000
---

[RSpec](http://rspec.info/) provides [some pretty good tools](http://rspec.info/documentation/mocks/) for mocking your objects in Rails test specs.

Mocks allow you to set expectations on what kind of messages are passed to your objects, and what values they pass back in return. Among other things, this brings the advantage that your test/example can be truly focused on one unit of code, because the data that the mocks (or stubs) return does not rely on the implementation of the objects or methods that they imitate.

In most cases, mocking with RSpec in your Rails tests is pretty straightforward - you just create the mock object and set your expectations of it:

```
# mock_model is a convenience provided by rspec_on_rails
my_mock = mock_model(User)
my_mock.should_receive(:authenticate).with('user', 'pass').and_return(true)
```

Alternatively, you can create partial mocks or stubs on real objects or classes:

```
# partial stub for a real object
u = User.new
u.stub!(:name).and_return('Phred')

# partial mock for a class method
User.should_receive(:find).and_return(u)
```

In all of these cases, there is a clear recipient for the mocking or stubbing treatment - a mock object, or real object, or a class. This is what you will mostly use in your model and controller specs.

However, if you are in the specs for your helpers, it's not self evident what the recipient should be. Here's an example for a helpers file with two helpers, one calling the other:

```
module ApplicationHelper
  def user_list(users)
    users.each { |u| user_summary(u) }
  end

  def user_summary(user)
    open :div, {:class => 'user_summary'} do
      open :p, user.name
      open :p, user.birthday
    end
  end
end
```

These helper methods all belong inside a module, and are not attached to any object or class like the ActiveRecord models in the above examples. So how do we mock a helper? Check it out:

```
require File.dirname( __FILE__ ) + '/../../spec_helper'

describe ApplicationHelper, "user printing helpers" do
  include ActionView::Helpers
  include Haml::Helpers

  it "should call the user_summary helper for each user object in the array passed to user_list" do
    user = mock_model(User) do |u|
      u.stub!(:name).and_return('Phred')
      u.stub!(:birthday).and_return('April')
    end
    users = []

    5.times do
      users << user
    end

    # This is the clincher!
    self.should_receive(:user_summary).exactly(5).times

    user_list(users)
  end
end
```

In your helper specs, the `self` object is what you can use to mock and stub your helpers. It's that simple. What is `self`? I'm not really quite sure. It looks like a dynamically created subclass of `Spec::Rails::Example::HelperExampleGroup` that is particular to the spec example currently being run. Whatever it is, it gets the job done for us.

If you also need to mock or stub your helpers in view specs, you can use the `@controller.template` object:

```
@controller.template.stub!(:a_helper_method).and_return(true)
```

Check out [Jack Scrugg's article](http://jakescruggs.blogspot.com/2007/03/mockingstubbing-partials-and-helper.html) for more detail about this.

