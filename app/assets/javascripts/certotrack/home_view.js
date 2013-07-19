Certotrack.HomeView = Backbone.View.extend(
  {
    el: '.page',
    template: JST['certotrack/templates/home'],

    render: function() {
      this.$el.html(this.template());
    }
  });