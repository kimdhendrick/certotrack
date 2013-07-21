Certotrack.HomeView = Backbone.View.extend(
  {
    el: '.page',
    template: JST['certotrack/templates/home'],

    render: function() {
      var myView = this;

      $.ajax({
        type: 'POST',
        url: '/signed_in',
        success: function(data) {
          if (data['signed_in']) {
            myView.$el.html(myView.template());
          }
          else {
            new Certotrack.WelcomeView().render();
          }

        }
      });
    }
  }
);