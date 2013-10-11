class CertificationPeriod < ActiveRecord::Base

  belongs_to :certification

  after_initialize :_default_values

  validates_date :start_date, :before => lambda { 100.years.from_now }, :after => lambda { 100.years.ago }
  validates :units_achieved, numericality: {greater_than_or_equal_to: 0}

  private

  def _default_values
    self.units_achieved ||= 0
  end
end
