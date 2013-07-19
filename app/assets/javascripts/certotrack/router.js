Certotrack.Router = Backbone.Router.extend(
  {
    routes: {
      '': 'home',
      'locations': 'locations'
    },

    home: function() {
      new Certotrack.HomeView().render();
    },

    locations: function() {
      new Certotrack.LocationsView().render();
    }
  }
);