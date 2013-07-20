window.Certotrack || (window.Certotrack = {});

$(document).ready(function () {
  console.log('starting router');
  new Certotrack.Router();
  Backbone.history.start();
});
