---
title: Configuring god to monitor Sphinx's searchd
permalink: 2008/09/10/configuring-god-to-monitor-sphinxs-searchd
published_at: 2008-09-10 12:55:00 +0000
---

[God](http://god.rubyforge.org/) is a server monitoring tool helpful for starting your server processes and keeping them running, all the while making sure they don't misbehave. In the Rails world, it appears to be used most commonly with packs of mongrels or thins. However, this is not to say it can't be used to monitor other software. For one of my recent work projects, we've been using God to monitor the searchd process that [Sphinx](http://sphinxsearch.com/) uses to serve results to search queries.

The configuration required for this can be based mostly on what you see around the place for thins or mongrels:

```
require 'yaml'

app_config = YAML.load(File.open(File.dirname( __FILE__ ) + "/config.yml"))['production']

God.watch do |w|
  w.group = "#{app_config['app_name']}-sphinx"
  w.name = w.group + "-1"

  w.interval = 30.seconds

  w.uid = app_config['user']
  w.gid = app_config['group']

  w.start = "searchd --config #{app_config['app_root']}/config/sphinx.conf"
  w.start_grace = 10.seconds
  w.stop = "searchd --config #{app_config['app_root']}/config/sphinx.conf --stop"
  w.stop_grace = 10.seconds
  w.restart = w.stop + " && " + w.start
  w.restart_grace = 15.seconds

  w.pid_file = File.join(app_config['app_root'], "tmp/pids/sphinx.pid")

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 100.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minutes
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
```

There are a number of other changes required for this configuration to work properly. Firstly, you will require a `config/config.yml` file, containing something like the following:

```
development: &production_settings
  app_name: myapp
  user: deployer
  group: deployer
  app_root: "/home/deployer/deployments/myapp.amc.org.au/current"
test:
  << *production_settings
production:
  << *production_settings
```

This config file sets the app's short name, the user and group to run the searchd process, and the path to the rails application root. We keep these settings in a yaml file because they are also used in a number of other places besides here. If you don't have this requirement, you can put all of these settings directly into your god config file.

The other requirement is that we make Sphinx use a configuration file that has a predictable name. The default Sphinx config file, when using [Pat Allen's](http://freelancing-gods.com/) awesome [Thinking Sphinx](http://ts.freelancing-gods.com/) plugin, has a file name contains the name of the current Rails environment. God can't use this to launch searchd, because it is does not run within the context of the Rails environment. To set location and name of the sphinx configuration file, set up a config/sphinx.yml file that contains something like this:

```
development: &production_settings
  config_file: /home/deployer/deployments/myapp.amc.org.au/current/config/sphinx.conf
  pid_file: /home/deployer/deployments/myapp.amc.org.au/current/tmp/pids/sphinx.pid
test:
  << *production_settings
production:
  << *production_settings
```

Thinking Sphinx respects these settings and uses them when it generates the Sphinx config file.

So that's about it. Make sure you've run `rake thinking_sphinx:index` at least once in your Rails app, to generate the Sphinx configuration and indexes, and then you are ready to start god and have your searchd automatically started and monitored!

