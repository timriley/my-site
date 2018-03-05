---
title: Generating semi-private, obfuscated resource sharing URLs in Rails
permalink: 2008/03/11/generating-semi-private-obfuscated-resource-sharing-urls-in-rails
published_at: 2008-03-11 12:25:00 +0000
---

Recently I was working on an app that required semi-private, obfuscated URLs for sharing pages and feeds with non-registered members, much like Backpack does for its page feeds. Specifically, I wanted a URL with a long code in it of some kind that would make it difficult to guess.

I could not find anything on the net addressing this kind of requirement, much less in a RESTful way, so I rolled up my sleeves and built one independently. Here's how I did it.

In this example, I want to share _Activity_ resources, which I am exposing in the typical way in Rails' routes.rb:

```
map.resources :users do |user|
  user.resources :activities, :path_prefix => '/:user_id'
end
```

This routes provides access to the 7 standard CRUD actions in the ActivitiesController: index, show, new, create, edit, update, destroy. The only one of these that relates to listing multiple activities is index, but that action is already used to display activities to logged in users. So, a new action is needed, which we shall called "shared". I will create 2 new named routes to provide access to this:

```
map.shared_activities '/:user_id/activities/shared/:key',
  :controller => 'activities', :action => 'shared', :conditions => { :method => :get }

map.formatted_shared_activities '/:user_id/activities/shared/:key.:format',
  :controller => 'activities', :action => 'shared', :conditions => { :method => :get }
```

Take note of the `:key` component of these paths. This is the private code required to 'unlock' the shared activity pages. The key belongs to Sharing objects:

```
class Sharing < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :key
  after_create :create_key

  private

  def create_key
    self.key = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
    self.save
  end
end
```

So, if a user wants to share his activities, he can create a sharing object, which generates the key for the URL that they can share with their non-registered friends. One of these URLs will look like this:

```
http://myapp.com/tim/activities/shared/a258f423366a2a07ffd3afec8c07f1bed8e07ba9
```

This will load the `shared` action in the activities controller, which is also protected by a before\_filter that will only allow access if the key in the URL is valid for the user.

```
class ActivitiesController < ApplicationController
  before_filter :login_required, :except => :shared
  before_filter :get_user
  before_filter :sharing_required, :only => :shared

  def shared
    @activities = @user.activities.paginate(:order => 'created_at DESC', :page => params[:page])
  end

  private

  def get_user
    @user = User.find_by_login(params[:user_id])
  end

  def sharing_required
    # pull the key out of the URL and verify that the user has one to match
    unless Sharing.find(:first, :conditions => ['user_id = ? AND key = ?', @user.id, params[:key] ])
      flash[:error] = 'You do not have permission to view this page'
      redirect_to '/'
    end
  end
end
```

To flesh out the implementation, all you need to do is the following:

- Add views for the shared action in the activities controller
- Write a builder view to output the sharing action in RSS ([explained here](http://www.railsjitsu.com/now-feeding-rss-in-rails-2-0))
- Include a sharing resource (nested under the user resource) in routes.rb and add a CRUD interface for creating and manipulating Sharing objects
