---
title: Capistrano task to selectively update crontabs
permalink: 2008/11/25/capistrano-task-to-selectively-update-crontabs
published_at: 2008-11-25 02:25:00 +0000
---

In a lot of our Rails projects, we need to throw a few entries into a user's crontab, for things like scheduled rake tasks or thinking sphinx updates.

However, we don't want to overwrite the entire crontab file whenever we want to add new entries or change the details of the existing ones.

Thus, I've devised a little technique to allow selective updates of the crontab. Take this demo and apply it where necessary in your capistrano deploy.rb file:

```
namespace :my_rake_task do
  task :add_cron_job, :roles => :app, :except => { :no_release => true } do
    tmpname = "/tmp/appname-crontab.#{Time.now.strftime('%s')}"
    # run crontab -l or echo '' instead because the crontab command will fail if the user has no pre-existing crontab file.
    # in this case, echo '' is run and the cap recipe won't fail altogether.
    run "(crontab -l || echo '') | grep -v 'rake my_rake_task' > #{tmpname}"
    run "echo '12 1,11,18 * * * cd #{current_path} && RAILS_ENV=production rake my_rake_task' >> #{tmpname}"
    run "crontab #{tmpname}"
    run "rm #{tmpname}"
  end
end
```

To step you through it, this task will dump the current crontab to a file, excluding the command that you care about, then add the command back to the bottom of the file, and install the crontab again, with all the other contents preserved. This will allow you to change the particular entry without clobbering the entire file. Nifty!

