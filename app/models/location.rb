class Location < ActiveRecord::Base

  belongs_to :customer
  validates_presence_of :customer

  def self.accessible_parameters
    [:name]
  end

  def to_s
    name
  end

end
