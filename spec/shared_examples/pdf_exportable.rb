shared_examples_for 'a controller that exports to pdf' do |args|

  it 'responds to pdf format' do
    subject.public_send(args[:load_method], Faker.new([create(args[:resource])]))

    get args[:action], format: 'pdf'

    response.headers['Content-Type'].should == 'application/pdf'
  end

  it 'calls PdfPresenter#present with data to export' do
    my_user = stub_admin
    sign_in my_user
    resource = create(args[:resource])
    fake_service = subject.public_send(args[:load_method], Faker.new([resource]))
    fake_pdf_presenter = Faker.new
    sort_params = {'sort' => 'name', 'direction' => 'asc'}
    PdfPresenter.should_receive(:new).with([resource], args[:report_title], sort_params).and_return(fake_pdf_presenter)

    get args[:action], {format: 'pdf'}.merge(sort_params)

    fake_service.received_messages.should == [args[:get_method]]
    fake_service.received_params[0].should == my_user

    fake_pdf_presenter.received_message.should == :present
  end

  it 'exports to file' do
    subject.public_send(args[:load_method], Faker.new([]))

    get args[:action], format: 'pdf'

    response.headers['Content-Disposition'].should == "attachment; filename=\"#{args[:filename]}.pdf\""
  end
end