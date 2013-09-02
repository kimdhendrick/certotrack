class CertificationPeriod < ActiveRecord::Base

  belongs_to :certification

  validate :_validate_start_date

  private

  def _validate_start_date
    if start_date.blank?
      errors.add(:last_certification_date, "can't be blank")
      return
    end

    if (start_date <= 100.years.ago || start_date >= 100.years.from_now)
      errors.add(:last_certification_date, 'is an invalid date')
    end
  end
end
