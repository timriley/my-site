---
title: Complex Nested Forms with Rails and Unobtrusive jQuery
permalink: 2009/10/13/complex-nested-forms-with-rails-and-unobtrusive-jquery
published_at: 2009-10-13 00:20:00 +0000
---

I came across Ryan Bates' [complex-form-examples](http://github.com/ryanb/complex-form-examples/) project when I needed to build a complex form recently. It's an excellent educational reference for building these complex forms in a Rails app. You know the kind of forms, the ones where you want to add or remove an arbitrary number of child associations of a parent record. True to form, the latest version of Ryan's example app uses Rails' new [`accepts_nested_attributes_for`](http://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#M002132), which lets you create, edit or delete the collection of associated child objects just by passing through the appropriate attributes to the parent record.

The example app works beautifully, but a couple of its approaches didn't match how I wanted to build my app:

- It uses inline JavaScript. The JavaScript triggers and code to dynamically add and remove parts of the form for child objects are mixed in with the rest of my page markup, not in `application.js` or another file dedicated to my JavaScript and behaviour.
- The JavaScript function to add fields to the form takes a string argument that contains _all_ the HTML markup for these forms. Now, I'm no expert, but this just didn't seem as clean or efficient as possible.
 [caption id="" align="alignnone" width="500.0"] ![Image from carsten_tb.](6fa184048ecd.jpg) Image from carsten\_tb.[/caption]

So when I incorporated Ryan's examples into my application, I made a couple of changes:

- All the JavaScript is unobtrusive. The behaviour is kept in my `application.js` along with the rest of my JavaScript.
- This means the page markup is cleaner. The links to add and remove child elements have no inline JS, just a certain class name for jQuery to hook onto.
- The JavaScript functions that add new fields to the form don't get given the markup for those fields in an argument. The fields are already in the form, wrapped in a div that is hidden with a `display: none` rule. The JavaScript function finds these fields in the DOM and then duplicates them and inserts them into the right place. In essence, the hidden fields act as a template.
- For the form to work with multiple child objects, the links to add new fields include an HTML5 [custom data attribute](http://dev.w3.org/html5/spec/Overview.html#custom-data-attribute) called `data-association` to store the appropriate association name for the child. The JavaScript uses this field to find the right hidden template fields (see above). Neat!
- All the JavaScript uses [jQuery](http://jquery.com), because that matched the rest of my application. No big deal.

I applied these changes to an [unobtrusive-jquery branch](http://github.com/timriley/complex-form-examples/tree/unobtrusive-jquery) in my fork of complex-form-examples. Please clone or fork it to take a look and make any improvements! I hope it can come in handy. Thanks to [Ryan Bates](http://www.workingwithrails.com/person/6491-ryan-bates) for his excellent work in building the example application.

