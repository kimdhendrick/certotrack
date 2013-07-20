Certotrack.WelcomeView = Backbone.View.extend(
  {
    el: '.page',
    template: JST['certotrack/templates/welcome'],

    render: function() {
      console.log('rendering welcome view');
      this.$el.html(this.template());
    },

    initialize: function() {
      console.log('initialized welcome view');
    }
});