shared_examples_for 'a controller that exports to csv' do |args|

  it 'responds to csv format' do
    subject.public_send(args[:load_method], Faker.new([create(args[:resource])]))

    get args[:action], format: 'csv'

    response.headers['Content-Type'].should == 'text/csv; charset=utf-8'
    response.body.split("\n").count.should == 2
  end

  it 'calls CsvPresenter#present with data to export' do
    my_user = stub_admin
    sign_in my_user
    resource = create(args[:resource])
    fake_service = subject.public_send(args[:load_method], Faker.new([resource]))

    fake_csv_presenter = Faker.new
    Export::CsvPresenter.should_receive(:new).with([resource]).and_return(fake_csv_presenter)

    get args[:action], format: 'csv'

    fake_service.received_messages.should == [args[:get_method]]
    fake_service.received_params[0].should == my_user unless args[:skip_user_assertion]

    fake_csv_presenter.received_message.should == :present
  end

  it 'exports to file' do
    subject.public_send(args[:load_method], Faker.new([]))

    get args[:action], format: 'csv'

    response.headers['Content-Disposition'].should == "attachment; filename=\"#{args[:filename]}.csv\""
  end
end