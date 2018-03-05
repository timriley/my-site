---
title: jQuery datepickers with constrained ranges in Rails forms
permalink: 2008/03/18/jquery-datepickers-with-constrained-ranges-in-rails-forms
published_at: 2008-03-18 11:20:00 +0000
---

One of the first things I've done since joining the AMC is dive into one of the projects currently in development and start fixing small bugs, to familiarise myself with the codebase and the kind of problems they are solving here. It's also been a good chance to pick up a few things.

One of these has been [jQuery](http://jquery.com/). One of the places we are using it is to provide [datepickers](http://docs.jquery.com/UI/Datepicker) in a form to create new _Exam_ records. Here's the view for the form partial:

```
%p
  = f.label :name
  %br/
  = f.text_field :name

%p
  = f.label :exam_date
  %br/
  = f.text_field :exam_date, {:value => full_date(@exam.exam_date)}

%h2 Registration Period

%p
  = f.label :open_date, 'From: '
  %br/
  = f.text_field :open_date, {:value => full_date(@exam.open_date)}
  %br/
  = f.label :close_date, 'To: '
  %br/
  = f.text_field :close_date, {:value => full_date(@exam.close_date)}
```

Mmm, [haml](http://haml.hamptoncatlin.com/). Also note the complete lack of JavaScript inside this view! This is because we are making use of _unobtrusive_ JavaScript, a technique which separates the JavaScript code from the presentation layer and places importance on allowing the views to degrade gracefully (that is, continue to work fully even when JavaScript support is not available).

In this way, our JavaScript is kept inside another file: `application.js`:

```
$(document).ready(function() {
  ////
  // ui.datepicker fields
  $('#exam_exam_date').datepicker();
  $('#exam_open_date').datepicker();
  $('#exam_close_date').datepicker();
});
```

This code initialises the datepickers and attaches them to the text fields with IDs of exam_exam_date, exam_open_date, and exam_close_date. The datepickers will appear when you click or focus any of these fields. They will let you select the a date from an interactive calendar and insert a string representation of that date into the text field.

All very good, but we have another requirement: that the dates available for selection inside the datepickers are constrained. Specifically, the open and close dates should not be after the exam date, and the close date should not be before the open date. These constraints can be set up by passing a function name to the datepickers when they are initialised:

```
$(document).ready(function() {
  ////
  // ui.datepicker fields
  $('#exam_exam_date').datepicker();
  $('#exam_open_date').datepicker({beforeShow: customRange});
  $('#exam_close_date').datepicker({beforeShow: customRange});

  function customRange(input) {
    return {
      // 8640000 is the number of milliseconds in a day
      // set the maxDate for registrations to be the day _before_ the exam date, or no limit if there is no exam date yet
      maxDate: $('#exam_exam_date').datepicker('getDate') ? new Date($('#exam_exam_date').datepicker('getDate') - 86400000) : null,
      // set the minDate for registration close to be the day _after_ registration open
      minDate: input.id == 'exam_close_date' ? ($('#exam_open_date').datepicker('getDate') ? new Date(new Date($('#exam_open_date').datepicker('getDate')).getTime() + 86400000) : null) : null
    }
  }
});
```

The customRange function above is called every time before the datepickers appear. It sets the maxDate and minDate properties of the datepicker. This allows the constraints for one field to vary depending on the dates the user has chosen for the others.

When you press save, all of the dates will be sent to the controller and saved to your record. However, if validation fails for some reason and the form is reloaded, and extra step is necessary to make sure the constraints continue to behave properly.

You see, the datepicker widgets are kind of dumb. If they are attached to a field that already contains a textual representation of a date (such as when your form is reloaded after failed validation), they will not set themselves to that date. You must do this manually. Here it is, in the final incarnation of `application.js`:

```
////
// Behaviours
$(document).ready(function() {
  ////
  // ui.datepicker fields
  $('#exam_exam_date').datepicker();
  $('#exam_open_date').datepicker({beforeShow: customRange});
  $('#exam_close_date').datepicker({beforeShow: customRange});

  // initialise the date in the datepickers from the text in the input fields
  // this is necessary for the page reload that occurs after a failed validation
  $('#exam_exam_date').datepicker('setDate', new Date($('#exam_exam_date').attr('value')));
  $('#exam_open_date').datepicker('setDate', new Date($('#exam_open_date').attr('value')));
  $('#exam_close_date').datepicker('setDate', new Date($('#exam_close_date').attr('value')));

  function customRange(input) {
    return {
      // 8640000 is the number of milliseconds in a day
      // set the maxDate for registrations to be the day _before_ the exam date, or no limit if there is no exam date yet
      maxDate: $('#exam_exam_date').datepicker('getDate') ? new Date($('#exam_exam_date').datepicker('getDate') - 86400000) : null,
      // set the minDate for registration close to be the day _after_ registration open
      minDate: input.id == 'exam_close_date' ? ($('#exam_open_date').datepicker('getDate') ? new Date(new Date($('#exam_open_date').datepicker('getDate')).getTime() + 86400000) : null) : null
    }
  }
});
```

What does this all give you?

1. JavaScript code that is separated from your views, keeping everything nice and clean
2. Datepickers that will appear when their text fields are focused
3. Constraints that prevent the user from selecting dates that are out of bounds
4. Properly initialised datepickers after a form reload, such that they will display the correct date for the fields when clicked, and still adhere to the proper constraints

All up, this amounts to a pretty solid set of date selection widgets. Thanks, jQuery.

