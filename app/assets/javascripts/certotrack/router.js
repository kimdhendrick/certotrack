Certotrack.Router = Backbone.Router.extend(
  {
    routes: {
      '': 'home',
      'home': 'home',
      'locations': 'locations',

      '*path':  'home'
    },

    home: function() {
      new Certotrack.HomeView().render();
    },

    locations: function() {
      new Certotrack.LocationsView().render();
    }
  }
);