class Equipment < ActiveRecord::Base
  attr_accessible :name,
                  :notes,
                  :serial_number,
                  :inspection_type,
                  :inspection_interval,
                  :last_inspection_date,
                  :expiration_date
end
