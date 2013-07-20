Certotrack.LocationsView = Backbone.View.extend(
  {
    el: '.page',
    template: JST['certotrack/templates/location/locations'],

    render: function() {
      this.$el.html(this.template());
    }
  }
);