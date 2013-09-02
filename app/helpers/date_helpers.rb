module DateHelpers
  def self.date_to_string(date)
    return '' if date.blank?
    date.strftime("%m/%d/%Y")
  end

  def self.string_to_date(date)
    return nil unless date.present?
    begin
      return Date.strptime(date, '%m/%d/%Y')
    rescue ArgumentError
      return nil
    end
  end
end