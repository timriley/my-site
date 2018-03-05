---
title: Testing for elements in ActiveRecord's XML output
permalink: 2008/04/18/testing-for-elements-in-activerecords-xml-output
published_at: 2008-04-18 03:25:00 +0000
---

Following on from my previous post about [customising ActiveRecord's to\_xml output](http://log.openmonkey.com/post/31406090), I have had to write specs to make sure a custom attribute I have added to a model's XML serialisation actually appears as expected.

ActiveSupport's Hash.from\_xml class method makes this a piece of cake. Instead of testing against the XML as a string or parsing it manually, you can turn it into a hash and get directly to the attribute you want. Behold:

```
describe Product do
  before(:each) do
    @product = Product.new
  end

  # net_price is the custom attribute I have added to the XML serialisation
  it "should include net price in XML serialisation" do
    @product.attributes = valid_product_attributes
    Hash.from_xml(@product.to_xml)['product']['net_price'].should == @product.net_price
  end
end
```
