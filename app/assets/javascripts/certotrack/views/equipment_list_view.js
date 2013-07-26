Certotrack.EquipmentListView = Backbone.View.extend(
  {
    template: JST['certotrack/templates/equipment/equipment_list'],

    initialize: function() {
      this.collection = new Certotrack.EquipmentCollection();
      this.collection.on('sync', this.render, this);
      this.collection.fetch();
    },

    render: function() {
      this.$el.html(this.template({records: this.collection.toJSON()}));
      return this;
    }
  }
);