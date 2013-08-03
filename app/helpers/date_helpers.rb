module DateHelpers
  def self.format(date)
    return '' if date.blank?
    date.strftime("%m/%d/%Y")
  end
end