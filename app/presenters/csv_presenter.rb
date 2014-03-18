class CsvPresenter

  attr_reader :collection

  def initialize(collection)
    @collection = collection || []

    unless collection.empty?
      klass = "#{@collection.first.class}Presenter".constantize
      @collection = @collection.map { |model| klass.new(model) }
    end
  end

  def present
    CSV.generate do |csv|
      equipment_header_names = 'Name, Serial Number, Status, Inspection Interval, Last Inspection Date, Inspection Type, Expiration Date, Assignee, Created Date'.split(',')
      equipment_column_names = 'name,serial_number,status_text,inspection_interval,last_inspection_date,inspection_type,expiration_date,assignee,created_at'.split(',')

      csv << equipment_header_names

      collection.each do |equipment|
        values = equipment_column_names.map do |column_name|
          equipment.public_send(column_name)
        end
        csv << values
      end
    end

  end
end