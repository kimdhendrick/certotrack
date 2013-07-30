class Equipment < ActiveRecord::Base

  belongs_to :customer

  def self.accessible_parameters
    [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes
    ]
  end
end
