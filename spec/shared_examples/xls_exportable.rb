shared_examples_for 'a controller that exports to xls' do |args|

  it 'responds to xls format' do
    subject.public_send(args[:load_method], Faker.new([create(args[:resource])]))

    get args[:action], format: 'xls'

    response.headers['Content-Type'].should == 'application/vnd.ms-excel'
  end

  it 'calls ExcelPresenter#present with data to export' do
    my_user = stub_admin
    sign_in my_user
    resource = args[:resource]
    fake_service = subject.public_send(args[:load_method], Faker.new([resource]))
    fake_xls_presenter = Faker.new
    ExcelPresenter.should_receive(:new).with([resource], args[:report_title]).and_return(fake_xls_presenter)

    get args[:action], format: 'xls'

    fake_service.received_messages.should == [args[:get_method]]
    fake_service.received_params[0].should == my_user

    fake_xls_presenter.received_message.should == :present
  end

  it 'exports to file' do
    subject.public_send(args[:load_method], Faker.new([]))

    get args[:action], format: 'xls'

    response.headers['Content-Disposition'].should == "attachment; filename=\"#{args[:filename]}.xls\""
  end
end