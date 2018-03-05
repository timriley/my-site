---
title: Importing Legacy Data in Rails
permalink: 2009/05/02/importing-legacy-data-in-rails
published_at: 2009-05-01 22:10:00 +0000
---

## How Did we Get Here?

Our current [work](http://www.amc.org.au/) project is a long-overdue rebuild of a critical business system as a modern Rails web app. We're building this thing according to agile practices to the best of our ability. Each week we provide a new, working release that is an incremental improvement on the last. We're not looking to replace the current system in a single swoop, and expect the new system to work alongside the old one for quite a while.

This means that we'll need to maintain the same data in both systems for the duration of their lives together. We don't want the new Rails app to access the data directly from the old app's database, since this would prevent us from following the conventions that makes working with Rails so pleasant. Instead, we've come up with a way to import the legacy data into a new database.

In doing this, I've built a Rails plugin to make the experience easier. It is called _Acts as Importable_ and it is now [available on GitHub](http://github.com/timriley/acts-as-importable). This article will show our technique for importing the legacy data and how Acts as Importable helps.

## Accessing the Legacy Data

We use ActiveRecord to access the legacy data. It takes a bit of legwork to shoehorn the legacy schema into ActiveRecord models, but once that is done, we have satisfactory access to the data we want to import.

The first thing we do is provide a `Legacy::Base` model from which all other legacy models can inherit. This provides a single place to define access to the legacy database.

```
class Legacy::Base < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "legacy_#{Rails.env}"

  acts_as_importable
end
```

You can setup the extra database connections in `config/database.yml`, like below. Our legacy connection is to an MS SQL server via ODBC. Tim Lucas has [an excellent tutorial](http://toolmantim.com/articles/getting_rails_talking_to_sqlserver_on_osx_via_odbc) on how to get that set up.

```
legacy_development:
  adapter: sqlserver
  mode: odbc
  dsn: LEGACY
  autocommit: true
  host: localhost
  username: NTDOMAIN\username
  password: password
```

Now, here are a couple of the legacy models that inherit from `Legacy::Base` to access the legacy database. For the sake of this article, consider the code examples to come from a quiz application with models for categories, questions, and responses.

```
class Legacy::Question < Legacy::Base
  set_table_name 'quiz_questions'
  set_primary_key 'QuestionNumber'

  belongs_to :category,
             :class_name => 'Legacy::Category',
             :foreign_key => 'CategoryCode'
end

class Legacy::Category < Legacy::Base
  set_table_name 'quiz_categories'
  set_primary_key 'Code'
end
```

These are simple examples, but you get the idea. `set_table_name` and `set_primary_key` are your friends when you have table names and keys that defy Rails' conventions. If you want to use ActiveRecord associations to access your legacy data, you will also want to become familiar with the options available for specifying things like the class, join table and column names. Check the rdocs for `has_many`, `belongs_to` and `has_and_belongs_to_many` and look out for options like `:class_name`, `:foreign_key`, `:join_table`, and `:association_foreign_key`.

## Converting the Legacy Data

Each of the legacy models provides a `to_model` method that returns a new model ready to be saved into the new, non-legacy database.

```
# New model
class Category < ActiveRecord::Base
end

# Legacy model
class Legacy::Category < Legacy::Base
  set_table_name 'quiz_categories'
  set_primary_key 'Code'

  def to_model
    ::Category.new do |c|
      c.name = self.Description
    end
  end
end
```

## Importing the Legacy Data

Now that the import rules are defined for all the legacy models we care about, how do we get them all into the new database? This is where [Acts as Importable](http://github.com/timriley/acts_as_importable) comes in. This plugin helps to smoothen the import of an entire system's worth of legacy data. You saw it enabled above in the `Legacy::Base` class:

```
class Legacy::Base < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "legacy_#{Rails.env}"

  acts_as_importable
end
```

Acts as importable will let you import your legacy models in different ways:

```
# Import a single question
Legacy::Question.import(123)
# or
Legacy::Question.find(123).import

# Import all questions
Legacy::Question.import_all

# Import all the questions, 1000 at a time
Legacy::Question.import_all_in_batches
```

These are all different ways of instantiating your legacy models, calling the `#to_model` method, and saving the returned object. The value of the plugin is that it adds a little bit of extra smarts to this basic premise.

### belongs\_to Relationships & Caching

Acts as Importable provides a `#lookup` class method for finding the new ID of an imported legacy model. When each legacy model is imported using the above methods, Acts as Importable saves the legacy model's class name and ID along with the rest of the data in new model (be sure to provide `legacy_class` and `legacy_id` columns for this to work). The first time you `lookup` a legacy record, it uses `ActiveRecord::Base#find` with the appropriate values for `legacy_class` and `legacy_id` as conditions. It will save the ID in a lookup hash in memory, so that the next time you want to lookup from the same ID, the result is returned without a trip to the database.

This is really best seen in action:

```
# New models
class Question < ActiveRecord::Base
  belongs_to :category
  has_many :responses, :dependent => :destroy
end
class Category < ActiveRecord::Base
  has_many :questions
end

# Legacy model
class Legacy::Question < Legacy::Base
  def to_model
    ::Question.new do |q|
      # import the category association
      q.category_id = Legacy::Category.lookup(self.category.try(:id__))
    end
  end
end
```

Setting the id for associations directly like this is important for conserving trips to the database importing a model's `belongs_to` relationships, just like the one above. Be wary when using lookups for large data sets, however, as it will likely consume quite a bit of memory to store the ID mappings.

As an aside, we use `#try(:id__)` on the legacy model to provide the ID for the lookup, because `#id` on a nil value actually returns its `#object_id`. If the associated object doesn't exist, we don't want to pass a bogus ID. Acts as Importable provides `Object#try` and the `ActiveRecord::Base#id__` to `id` alias for you.

The lookups will work automatically if the class name of the model you're importing is the same as the legacy model's, eg. `Legacy::Question` to `Question`. If the class name of the model you're creating is different, you can tell that to Acts as Importable so that the lookups can continue to work:

```
# New model
class DifferentThing < ActiveRecord::Base
end

# Legacy model
class Legacy::Thing
  acts_as_importable :to => 'DifferentThing'

  def to_model
    ::DifferentThing.new
  end
end
```

### has\_many Relationships & Building

You can import `has_many` relationships quite easily, using the `#build` method on the association proxy. Here it is in action, expanding on the Question's `#to_model` method from above:

```
# New models
class Question < ActiveRecord::Base
  belongs_to :category
end
class Response < ActiveRecord::Base
  belongs_to :question
end

# Legacy model
class Legacy::Question < Legacy::Base
  def to_model
    ::Question.new do |q|
      q.category_id = Legacy::Category.lookup(self.category.try(:id__))

      # Build the responses
      (1..5).each do |i|
        q.responses.build(:body => self.send(:"response_#{i}"))
      end
    end
  end
end
```

When you save the new model, the newly built associated models are saved too.

### Importing Large Sets of Legacy Records

We ran into some slowness importing legacy models with large numbers of records, or with other models with large amounts of data in particular fields. To get around this, we use `#import_all_in_batches`, which only retrieves 1000 models at a time for processing. This is based on Jamis Buck's technique for [faking cursors in ActiveRecord](http://weblog.jamisbuck.org/2007/4/6/faking-cursors-in-activerecord), and as such, it requires a numeric primary key for the legacy models (you'd normally expect this to be the case, but it isn't for a few of our legacy tables).

### Idempotence of Imports

As I mentioned in the introduction, the legacy app we're replacing will remain in use as we incrementally build the new system. We will need to continue to synchronise the legacy data with the new system during this time. We'll therefore need our import process to be [idempotent](http://en.wikipedia.org/wiki/Idempotence), meaning that multiple imports can run and result in the same set of data at the other end. Mostly, this just means that we'll want to avoid creation of duplicate records in the new database.

We approach this pretty simply. Each night the old records are deleted and new ones re-imported in their place. You'll want to pick an approach that best suits your situation.

There is one complication, however, insofar as the new system is used to create some entirely new content that relates to the imported models. If models are deleted and re-imported from the legacy system every night, their IDs would be different each time. To get around this, we hard-code the ID of certain imported models to the same value as their respective legacy model's ID. This is very simply done:

```
class Legacy::Question < Legacy::Base
  def to_model
    ::Question.new do |q|
      # Hard-code the ID
      q.id = self.id

      q.category_id = Legacy::Category.lookup(self.category.try(:id__))

      (1..5).each do |i|
        q.responses.build(:body => self.send(:"response_#{i}"))
      end
    end
  end
end
```

## Final steps

There are two final pieces to our import system. Firstly, a way to control the order of the imports:

```
class Legacy::Importer
  def self.run
    Legacy::Category.import_all
    Legacy::Question.import_all_in_batches

    # Flush all the lookup tables
    Legacy::Category.flush_lookups!
    Legacy::Question.flush_lookups!
  end
end
```

It is important to control the order if your imported models are going to relate to each other. Some records will need to exist before the others can link to them.

And finally, a rake task:

```
namespace :legacy do
  desc "Import the legacy data."
  task :import => :environment do
    Legacy::Importer.run
  end
end
```

That's it! This approach certainly works to our liking, but I would love to hear your thoughts on this issue. Please feel free to post a comment below.

## Further Reading

These articles were of great use in getting our legacy imports up and running:

- [Sharing External ActiveRecord Connections](http://pragdave.blogs.pragprog.com/pragdave/2006/01/sharing_externa.html)
- [Using ActiveRecord to Migrate Legacy Data](http://www.pathf.com/blogs/2008/03/using-activerec/)
