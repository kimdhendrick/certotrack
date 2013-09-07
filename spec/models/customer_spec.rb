require 'spec_helper'

describe Customer do

  it { should have_many :certification_types }
  it { should have_many :equipments }
  it { should have_many :certifications }
  it { should have_many :employees }
  it { should have_many :locations }
  it { should have_many :users }
end