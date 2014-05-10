// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require tilt-jade/runtime
//= require jquery.chained.remote.js
//= require jquery.chained.js
//= require jquery-ui-1.10.3.custom.js
//= require certotrack.js

$(function(){ $(document).foundation(); });

$(function() {
  $('.datepicker').datepicker(
    {
      dateFormat: 'mm/dd/yy',
      changeYear: true
    });

  $('.ui-datepicker-trigger').on('click', function(e) {
    $(e.target).parent().prev().find('input').datepicker('show');
  });
});