Certotrack.Router = Backbone.Router.extend(
  {
    routes: {
      '': 'home',
      'welcome': 'welcome',
      'home': 'home',
      'locations': 'locations'
    },

    welcome: function() {
      console.log('in welcome');
      new Certotrack.WelcomeView().render();
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