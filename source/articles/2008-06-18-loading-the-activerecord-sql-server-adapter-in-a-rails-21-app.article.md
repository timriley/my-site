---
title: Loading the ActiveRecord SQL Server adapter in a Rails 2.1 app
permalink: 2008/06/18/loading-the-activerecord-sql-server-adapter-in-a-rails-21-app
published_at: 2008-06-18 03:30:00 +0000
---

It's pretty simple. In your config/environment.rb:

```
config.gem 'activerecord-sqlserver-adapter', :source => 'http://gems.rubyonrails.org', :lib => 'active_record/connection_adapters/sqlserver_adapter'
```

Then run rake gems:install and away you go.

Hugh has [some more tips](http://hughevans.net/2008/05/25/rails-ubuntu-odbc) about the packages and configuration required to connect to an SQL Server from a Linux platform.

