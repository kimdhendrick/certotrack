module Export
  module CustomerHeaderColumnMapping
    HEADERS = 'Name,Account Number,Contact Person Name,Contact Email,Contact Phone Number,Address 1,Address 2,City,State,Zip,Active,Equipment Access,Certification Access,Vehicle Access,Created Date'.split(',')
    COLUMNS = [:name, :account_number, :contact_person_name, :contact_email, :contact_phone_number, :address1, :address2, :city, :state, :zip, :active, :equipment_access, :certification_access, :vehicle_access, :created_at]
  end
end