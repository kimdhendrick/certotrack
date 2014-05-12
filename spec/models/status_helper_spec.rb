require 'spec_helper'

describe StatusHelper do

  class TestSortableByStatus
    include StatusHelper
  end

  subject { TestSortableByStatus.new }

  it 'should force subclass to implement #status' do
    expect { subject.status }.to raise_error(NotImplementedError)
  end

  it_behaves_like 'an object that is sortable by status'
end