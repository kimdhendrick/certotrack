module DateHelpers
  def self.date_to_string(date)
    return '' if date.blank?
    date.strftime("%m/%d/%Y")
  end
end