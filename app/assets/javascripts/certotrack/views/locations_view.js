Certotrack.LocationsView = Backbone.View.extend(
  {
    template: JST['certotrack/templates/location/locations'],

    render: function() {
      this.$el.html(this.template());
      return this;
    }
  }
);