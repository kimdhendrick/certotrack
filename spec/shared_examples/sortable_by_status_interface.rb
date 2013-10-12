shared_examples_for 'an object that is sortable by status' do
  it 'responds to #status' do
    subject.should respond_to(:status)
  end

  it 'responds to #status_code' do
    subject.should respond_to(:status_code)
  end
end