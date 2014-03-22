class CertificationType < ActiveRecord::Base
  include DeletionPrevention

  belongs_to :customer
  has_many :certifications, autosave: true

  after_initialize :_default_values
  before_validation :_strip_whitespace

  validates_presence_of :name,
                        :customer,
                        :created_by

  validates_uniqueness_of :name, scope: :customer_id, case_sensitive: false
  validates :units_required, :numericality => { :greater_than_or_equal_to => 0 }
  validates :interval, inclusion: {in: Interval.all.map(&:text),
                                              message: 'invalid value'}

  before_destroy :_prevent_deletion_when_certifications

  def units_based?
    units_required > 0
  end

  def has_valid_certification?
    valid_certifications.present?
  end

  def valid_certifications
    self.certifications.select { |certification| certification.current? }
  end

  private

  def _prevent_deletion_when_certifications
    prevent_deletion_of(certifications,
                         'This Certification Type is assigned to existing Employee(s). You must uncertify the employee(s) before removing it.')
  end

  def _default_values
    self.units_required ||= 0
  end

  def _strip_whitespace
    self.name.try(:strip!)
  end
end