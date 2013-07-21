Certotrack.Router = Backbone.Router.extend(
  {
    routes: {
      '': 'home',
      'home': 'home',
      'locations': 'locations',

      '*path':  'home'
    },

    home: function() {
      console.log('routing to home');
      new Certotrack.HomeView().render();
    },

    locations: function() {
      new Certotrack.LocationsView().render();
    }
  }
);