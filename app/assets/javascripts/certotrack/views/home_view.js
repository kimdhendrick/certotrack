Certotrack.HomeView = Backbone.View.extend(
  {
    template: JST['certotrack/templates/home'],

    render: function() {
      this.$el.html(this.template());
      return this;
    }
  }
);