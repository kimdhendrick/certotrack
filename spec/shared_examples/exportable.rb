shared_examples_for 'a controller that exports to csv, xls, and pdf' do |args|

  it_behaves_like 'a controller that exports to csv', args
  it_behaves_like 'a controller that exports to xls', args
  it_behaves_like 'a controller that exports to pdf', args

end