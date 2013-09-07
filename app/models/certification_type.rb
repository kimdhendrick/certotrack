class CertificationType < ActiveRecord::Base

  after_initialize :_default_values

  belongs_to :customer
  has_many :certifications

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :customer_id
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

end