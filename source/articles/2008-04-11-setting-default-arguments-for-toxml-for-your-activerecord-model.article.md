---
title: Setting default arguments for to_xml for your ActiveRecord model
permalink: 2008/04/11/setting-default-arguments-for-toxml-for-your-activerecord-model
published_at: 2008-04-11 02:45:00 +0000
---

Rails provides you with a lot of [scope for customising](http://api.rubyonrails.com/classes/ActiveRecord/Serialization.html#M001137) the XML serialisation of models with to\_xml. Among other things, you can exclude attributes, include objects that are first-level associations, and include the results of any custom methods for your model.

However, most of the examples for these only show this customisation taking place in the scope of the controller, where the arguments are passed to a single call of to_xml. This is not very DRY if you want to customise the default to_xml output for your model to include or exclude some information.

Customising the default behaviour is pretty easy. Say I have an extra method inside a model that combines price and tax to formulate a net price, and I want this to be included in the XML serialisation every time. Here is what to do:

```
class Product < ActiveRecord::Base
  def net_price
    self.price + self.tax
  end

  alias_method :ar_to_xml, :to_xml

  def to_xml(options = {}, &block)
    default_options = { :methods => [:net_price]}
    self.ar_to_xml(default_options.merge(options), &block)
  end
end
```
