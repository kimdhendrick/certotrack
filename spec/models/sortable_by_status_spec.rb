require 'spec_helper'

describe SortableByStatus do

  class TestSortableByStatus
    include SortableByStatus
  end

  subject { TestSortableByStatus.new }

  it "should force subclass to implement #status" do
    expect { subject.status }.to raise_error(NotImplementedError)
  end

  it_behaves_like "sortable by status"
end