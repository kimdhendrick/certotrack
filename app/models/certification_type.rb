class CertificationType < ActiveRecord::Base

  belongs_to :customer
  has_many :certifications

  after_initialize :_default_values
  before_validation :_strip_whitespace

  validates_presence_of :name,
                        :customer

  validates_uniqueness_of :name, scope: :customer_id, case_sensitive: false
  validates :units_required, :numericality => { :greater_than_or_equal_to => 0 }
  validates :interval, inclusion: {in: Interval.all.map(&:text),
                                              message: 'invalid value'}

  def units_based?
    units_required > 0
  end

  def interval_code
    Interval.lookup(interval)
  end

  def to_s
    "#{name}:#{interval}"
  end

private

  def _default_values
    self.units_required ||= 0
  end

  def _strip_whitespace
    self.name.try(:strip!)
  end

end