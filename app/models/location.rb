class Location < ActiveRecord::Base

  belongs_to :customer

  before_validation :_strip_whitespace

  validates_presence_of :customer
  validates_uniqueness_of :name, scope: :customer_id, case_sensitive: false

  def self.accessible_parameters
    [:name]
  end

  def to_s
    name
  end

  def sort_key
    name
  end

  private

  def _strip_whitespace
    self.name.try(:strip!)
  end

end
