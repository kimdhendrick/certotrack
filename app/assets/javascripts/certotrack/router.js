Certotrack.Router = Backbone.Router.extend(
  {
    routes: {
      '': 'home',
      'home': 'home',
      'locations': 'locations',
      'equipment': 'equipment',

      '*path': 'home'
    },

    home: function() {
      this._routeTo(Certotrack.HomeView);
    },

    locations: function() {
      this._routeTo(Certotrack.LocationsView);
    },

    equipment: function() {
      this._routeTo(Certotrack.EquipmentListView);
    },

    _routeTo: function(View) {
      $('#certotrack-content').html(new View().render().el);
    }

  }
);