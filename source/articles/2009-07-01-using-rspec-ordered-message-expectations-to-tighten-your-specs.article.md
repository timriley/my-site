---
title: Using RSpec Ordered Message Expectations to Tighten your Specs
permalink: 2009/07/01/using-rspec-ordered-message-expectations-to-tighten-your-specs
published_at: 2009-07-01 13:35:00 +0000
---

I quite enjoy the competitive undercurrent of ping pong pair programming. As the person writing the implementation code, it is fun to write something that will turn a test green, but still not necessarily do what my partner was expecting. Taking this approach has also been helpful for improving our specs. Take this example controller spec:

```
describe ArticlesController do
  describe "handling create" do
    before(:each) do
      @article = mock_model(Article, :save => nil)
      Article.stub(:new).and_return(@article)

      @user = mock_model(User)
      controller.stub(:current_user).and_return(@user)
    end

    it "should build a new article from posted data" do
      Article.should_receive(:new).with('title' => 'Test Post')
      post :create, :article => {:title => 'Test Post'}
    end

    it "should assign the current user as the article's author" do
      @article.should_receive(:author=).with(@user)
      post :create
    end

    it "should save the article"
      @article.should_receive(:save)
      post :create
    end
  end
end
```

This looks like a reasonable set of concise, clear examples, but you can easily make them all pass and without building a controller action that does what you expect:

```
class ArticlesController < ApplicationController
  def create
    @article = Article.new(params[:article])
    @article.save
    @article.author = current_user
  end
end
```

This satisfies the examples, but saving the article _before_ assigning the current user as author isn't what we would have intended. Enter RSpec's [ordered message expectations](http://rspec.info/documentation/mocks/message_expectations.html). These allow you to specify the order in which you expect an object to receive message calls.

```
describe ArticlesController do
  describe "handling create" do
    it "should save the article after assigning the current user as author"
      @article.should_receive(:author=).with(@user).ordered
      @article.should_receive(:save).ordered
      post :create
    end
  end
end
```

This example would fail with the above controller action, and force us to write it properly:

```
class ArticlesController < ApplicationController
  def create
    @article = Article.new(params[:article])
    @article.author = current_user
    @article.save
  end
end
```

The result is a controller that does what you expect, a stronger set of specs, and an increased capacity for true behaviour driven development. Win, win, win!

