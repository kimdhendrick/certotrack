require 'spec_helper'

describe CertificationsController do

  let(:customer) { create(:customer) }
  let(:certification) { build(:certification) }
  let(:fake_certification_service_that_returns_list) { Faker.new([certification]) }
  let(:faker_that_returns_empty_list) { Faker.new([]) }
  let(:big_list_of_certifications) do
    big_list_of_certifications = []
    30.times do
      big_list_of_certifications << create(:service)
    end
    big_list_of_certifications
  end

  describe 'GET #index' do
    it 'calls get_all_certifications with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_certification_service = controller.load_certification_service(faker_that_returns_empty_list)
      fake_certification_list_presenter = Faker.new([])
      CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :index, params

      fake_certification_service.received_messages.should == [:get_all_certifications]
      fake_certification_service.received_params[0].should == my_user

      fake_certification_list_presenter.received_message.should == :present
      fake_certification_list_presenter.received_params[0]['sort'].should == 'name'
      fake_certification_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns certifications' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :index

        assigns(:certifications).map(&:model).should eq([certification])
      end

      it 'assigns certifications_count' do
        controller.load_certification_service(Faker.new(big_list_of_certifications))

        get :index, {per_page: 25, page: 1}

        assigns(:certification_count).should eq(30)
      end

      it 'assigns report_title' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :index

        assigns(:report_title).should eq('All Employee Certifications')
      end

      it 'sets export_template' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :index

        assigns(:export_template).should == 'all_certification_export'
      end

      context 'export' do
        subject { controller }
        it_behaves_like 'a controller that exports to csv, xls, and pdf',
                        resource: :certification,
                        load_method: :load_certification_service,
                        get_method: :get_all_certifications,
                        action: :index,
                        report_title: 'All Employee Certifications',
                        filename: 'certifications'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certifications' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :index

        assigns(:certifications).map(&:model).should eq([certification])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign certifications' do
          get :index

          assigns(:certifications).should be_nil
        end
      end
    end
  end

  describe 'GET #expired' do
    it 'calls get_expired with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_certification_service = controller.load_certification_service(faker_that_returns_empty_list)
      fake_certification_list_presenter = Faker.new([])
      CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :expired, params

      fake_certification_service.received_messages.should == [:get_expired_certifications]
      fake_certification_service.received_params[0].should == my_user

      fake_certification_list_presenter.received_message.should == :present
      fake_certification_list_presenter.received_params[0]['sort'].should == 'name'
      fake_certification_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      context 'HTML format' do
        it 'assigns certifications' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :expired

          assigns(:certifications).map(&:model).should eq([certification])
        end

        it 'assigns certifications_count' do
          controller.load_certification_service(Faker.new(big_list_of_certifications))

          get :expired, {per_page: 25, page: 1}

          assigns(:certification_count).should eq(30)
        end

        it 'assigns report_title' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :expired

          assigns(:report_title).should eq('Expired Certifications')
        end

        it 'sets export_template' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :expired

          assigns(:export_template).should == 'expired_certification_export'
        end
      end

      context 'export' do
        subject { controller }
        it_behaves_like 'a controller that exports to csv, xls, and pdf',
                        resource: :certification,
                        load_method: :load_certification_service,
                        get_method: :get_expired_certifications,
                        action: :expired,
                        report_title: 'Expired Certifications',
                        filename: 'expired_certifications'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certifications' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :expired

        assigns(:certifications).map(&:model).should eq([certification])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET expired' do
        it 'does not assign certifications' do
          get :expired

          assigns(:certifications).should be_nil
        end
      end
    end
  end

  describe 'GET #expiring' do
    it 'calls get_expiring with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_certification_service = controller.load_certification_service(faker_that_returns_empty_list)
      fake_certification_list_presenter = Faker.new([])
      CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :expiring, params

      fake_certification_service.received_messages.should == [:get_expiring_certifications]
      fake_certification_service.received_params[0].should == my_user

      fake_certification_list_presenter.received_message.should == :present
      fake_certification_list_presenter.received_params[0]['sort'].should == 'name'
      fake_certification_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      context 'HTML format' do
        it 'assigns certifications' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :expiring

          assigns(:certifications).map(&:model).should eq([certification])
        end

        it 'assigns certifications_count' do
          controller.load_certification_service(Faker.new(big_list_of_certifications))

          get :expiring, {per_page: 25, page: 1}

          assigns(:certification_count).should eq(30)
        end

        it 'assigns report_title' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :expiring

          assigns(:report_title).should eq('Certifications Expiring Soon')
        end

        it 'sets export_template' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :expiring

          assigns(:export_template).should == 'expiring_certification_export'
        end
      end

      context 'export' do
        subject { controller }
        it_behaves_like 'a controller that exports to csv, xls, and pdf',
                        resource: :certification,
                        load_method: :load_certification_service,
                        get_method: :get_expiring_certifications,
                        action: :expiring,
                        report_title: 'Certifications Expiring Soon',
                        filename: 'expiring_certifications'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certifications' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :expiring

        assigns(:certifications).map(&:model).should eq([certification])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET expiring' do
        it 'does not assign certifications' do
          get :expiring

          assigns(:certifications).should be_nil
        end
      end
    end
  end

  describe 'GET #units_based' do
    it 'calls get_units_based with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_certification_service = controller.load_certification_service(faker_that_returns_empty_list)
      fake_certification_list_presenter = Faker.new([])
      CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :units_based, params

      fake_certification_service.received_messages.should == [:get_units_based_certifications]
      fake_certification_service.received_params[0].should == my_user

      fake_certification_list_presenter.received_message.should == :present
      fake_certification_list_presenter.received_params[0]['sort'].should == 'name'
      fake_certification_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      context 'HTML format' do
        it 'assigns certifications' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :units_based

          assigns(:certifications).map(&:model).should eq([certification])
        end

        it 'assigns certifications_count' do
          controller.load_certification_service(Faker.new(big_list_of_certifications))

          get :units_based, {per_page: 25, page: 1}

          assigns(:certification_count).should eq(30)
        end

        it 'assigns report_title' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :units_based

          assigns(:report_title).should eq('Units Based Certifications')
        end

        it 'sets export_template' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :units_based

          assigns(:export_template).should == 'units_based_certification_export'
        end
      end

      context 'export' do
        subject { controller }
        it_behaves_like 'a controller that exports to csv, xls, and pdf',
                        resource: :certification,
                        load_method: :load_certification_service,
                        get_method: :get_units_based_certifications,
                        action: :units_based,
                        report_title: 'Units Based Certifications',
                        filename: 'units_based_certifications'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certifications' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :units_based

        assigns(:certifications).map(&:model).should eq([certification])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET units_based' do
        it 'does not assign certifications' do
          get :units_based

          assigns(:certifications).should be_nil
        end
      end
    end
  end

  describe 'GET #recertification_required' do
    it 'calls get_recertification_required with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_certification_service = controller.load_certification_service(faker_that_returns_empty_list)
      fake_certification_list_presenter = Faker.new([])
      CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :recertification_required, params

      fake_certification_service.received_messages.should == [:get_recertification_required_certifications]
      fake_certification_service.received_params[0].should == my_user

      fake_certification_list_presenter.received_message.should == :present
      fake_certification_list_presenter.received_params[0]['sort'].should == 'name'
      fake_certification_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      context 'HTML format' do
        it 'assigns certifications' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :recertification_required

          assigns(:certifications).map(&:model).should eq([certification])
        end

        it 'assigns certifications_count' do
          controller.load_certification_service(Faker.new(big_list_of_certifications))

          get :recertification_required, {per_page: 25, page: 1}

          assigns(:certification_count).should eq(30)
        end

        it 'assigns report_title' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :recertification_required

          assigns(:report_title).should eq('Recertification Required Certifications')
        end

        it 'sets export_template' do
          controller.load_certification_service(fake_certification_service_that_returns_list)

          get :recertification_required

          assigns(:export_template).should == 'recertification_required_certification_export'
        end
      end

      context 'export' do
        subject { controller }
        it_behaves_like 'a controller that exports to csv, xls, and pdf',
                        resource: :certification,
                        load_method: :load_certification_service,
                        get_method: :get_recertification_required_certifications,
                        action: :recertification_required,
                        report_title: 'Recertification Required Certifications',
                        filename: 'recertification_required_certifications'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certifications' do
        controller.load_certification_service(fake_certification_service_that_returns_list)

        get :recertification_required

        assigns(:certifications).map(&:model).should eq([certification])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET #recertification_required' do
        it 'does not assign certifications' do
          get :recertification_required

          assigns(:certifications).should be_nil
        end
      end
    end
  end

  describe 'GET #new' do
    context 'when certification user' do
      let (:current_user) { stub_certification_user(customer) }

      before do
        sign_in current_user
      end

      it 'calls certification service with employee_id' do
        controller.load_certification_type_service(Faker.new)
        employee = create(:employee)
        certification = create(:certification, employee: employee, customer: employee.customer)
        fake_certification_service = controller.load_certification_service(Faker.new(certification))

        get :new, {employee_id: employee.id}, {}

        fake_certification_service.received_message.should == :new_certification
        fake_certification_service.received_params[0].should == current_user
        fake_certification_service.received_params[1].should == employee.id.to_s
      end

      it 'calls certification service with certification_type_id' do
        controller.load_certification_type_service(Faker.new)
        certification_type = create(:certification_type)
        certification = create(:certification, certification_type: certification_type, customer: certification_type.customer)
        fake_certification_service = controller.load_certification_service(Faker.new(certification))

        get :new, {certification_type_id: certification_type.id}, {}

        fake_certification_service.received_message.should == :new_certification
        fake_certification_service.received_params[0].should == current_user
        fake_certification_service.received_params[1].should == nil
        fake_certification_service.received_params[2].should == certification_type.id.to_s
      end

      it 'assigns @certification' do
        controller.load_certification_type_service(Faker.new)
        certification = create(:certification, customer: create(:customer))
        controller.load_certification_service(Faker.new(certification))

        get :new, {}, {}

        assigns(:certification).should == certification
      end

      it 'assigns @source when employee' do
        controller.load_certification_service(Faker.new)
        certification_type = create(:certification_type)
        controller.load_certification_type_service(Faker.new([certification_type]))

        get :new, {source: 'employee'}, {}

        assigns(:source).should eq('employee')
      end

      it 'assigns @source when certification_type' do
        controller.load_certification_service(Faker.new)
        certification_type = create(:certification_type)
        controller.load_certification_type_service(Faker.new([certification_type]))

        get :new, {source: 'certification_type'}, {}

        assigns(:source).should eq('certification_type')
      end

      it 'calls certification_type_service' do
        controller.load_certification_service(Faker.new)
        fake_certification_type_service = controller.load_certification_type_service(faker_that_returns_empty_list)

        get :new, {}, {}

        fake_certification_type_service.received_message.should == :get_all_certification_types
        fake_certification_type_service.received_params[0].should == current_user
      end

      it 'assigns certification_types' do
        controller.load_certification_service(Faker.new)
        certification_type = create(:certification_type)
        controller.load_certification_type_service(Faker.new([certification_type]))

        get :new, {}, {}

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end

      it 'assigns employees' do
        controller.load_certification_service(Faker.new)
        employee = create(:employee)
        controller.load_employee_service(Faker.new([employee]))

        get :new, {}, {}

        assigns(:employees).map(&:model).should eq([employee])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns certification_types' do
        certification_type = build(:certification_type)
        controller.load_certification_type_service(Faker.new([certification_type]))
        controller.load_certification_service(Faker.new)

        get :new, {}, {}

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end

      it 'assigns employees' do
        controller.load_certification_service(Faker.new)
        employee = create(:employee)
        controller.load_employee_service(Faker.new([employee]))

        get :new, {}, {}

        assigns(:employees).map(&:model).should eq([employee])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certifications_types' do
        get :new, {}, {}
        assigns(:certification_types).should be_nil
      end

      it 'does not assign employees' do
        get :new, {}, {}
        assigns(:employees).should be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when certification user' do
      let (:current_user) { stub_certification_user(customer) }
      before do
        sign_in current_user
      end

      it 'calls creates certification using CertificationService' do
        fake_certification_service = controller.load_certification_service(Faker.new(build(:certification)))

        params = {
          certification: {
            employee_id: 99,
            certification_type_id: 1001,
            last_certification_date: '3/3/2003',
            trainer: 'John Jacob Jingle',
            comments: 'my name too',
            units_achieved: '15'
          },
          source: :employee,
          commit: 'Create'
        }

        post :create, params, {}

        fake_certification_service.received_message.should == :certify
        fake_certification_service.received_params[0].should == current_user
        fake_certification_service.received_params[1].should == '99'
        fake_certification_service.received_params[2].should == '1001'
        fake_certification_service.received_params[3].should == '3/3/2003'
        fake_certification_service.received_params[4].should == 'John Jacob Jingle'
        fake_certification_service.received_params[5].should == 'my name too'
        fake_certification_service.received_params[6].should == '15'
      end

      it 're-renders new on error' do
        controller.load_certification_type_service(Faker.new([build(:certification_type)]))
        certification = build(:certification)
        certification.stub(:valid?).and_return(false)
        controller.load_certification_service(Faker.new(certification))

        post :create, {employee: {}, certification: {}}, {}

        response.should render_template('new')
      end

      it 'assigns @certification on error' do
        controller.load_certification_type_service(Faker.new)
        certification = build(:certification)
        certification.stub(:valid?).and_return(false)
        controller.load_certification_service(Faker.new(certification))

        get :create, {certification: {employee_id: 1, certification_type_id: 1}}, {}

        assigns(:certification).should == certification
      end

      it 'calls certification_type_service on error' do
        certification = build(:certification)
        certification.stub(:valid?).and_return(false)
        controller.load_certification_service(Faker.new(certification))
        certification_type = create(:certification_type)
        fake_certification_type_service = controller.load_certification_type_service(Faker.new([certification_type]))

        get :create, {employee: {}, certification: {}}, {}

        fake_certification_type_service.received_message.should == :get_all_certification_types
        fake_certification_type_service.received_params[0].should == current_user
      end

      it 'assigns certification_types on error' do
        certification = build(:certification)
        certification.stub(:valid?).and_return(false)
        controller.load_certification_service(Faker.new(certification))
        certification_type = create(:certification_type)
        controller.load_certification_type_service(Faker.new([certification_type]))

        get :create, {employee: {}, certification: {}}, {}

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end

      it 'assigns employees on error' do
        certification = build(:certification)
        certification.stub(:valid?).and_return(false)
        controller.load_certification_service(Faker.new(certification))
        employee = create(:employee)
        controller.load_employee_service(Faker.new([employee]))

        get :create, {employee: {}, certification: {}}, {}

        assigns(:employees).map(&:model).should eq([employee])
      end

      it 'handles missing employee_id' do
        params = {
          employee: {id: nil},
          certification: {}
        }

        post :create, params, {}

        response.should render_template('new')
      end

      context 'Create' do
        it 'redirects to show employee page on success when source is :employee' do
          employee = create(:employee)
          certification_type = create(:certification_type)
          certification = create(:certification, employee: employee, certification_type: certification_type, customer: employee.customer)

          controller.load_certification_service(Faker.new(certification))

          params = {
            certification: {
              employee_id: 1,
              certification_type_id: 1
            },
            source: :employee,
            commit: 'Create'
          }

          post :create, params, {}

          response.should redirect_to(employee)
        end

        it 'redirects to show certification type page on success when source is :certification_type' do
          employee = create(:employee)
          certification_type = create(:certification_type)
          certification = create(:certification, employee: employee, certification_type: certification_type, customer: employee.customer)

          controller.load_certification_service(Faker.new(certification))

          params = {
            certification: {
              employee_id: 1,
              certification_type_id: 1
            },
            source: :certification_type,
            commit: 'Create'
          }

          post :create, params, {}

          response.should redirect_to(certification_type)
        end

        it 'redirects to show certification type page on success when source is :certification' do
          employee = create(:employee)
          certification_type = create(:certification_type)
          certification = create(:certification, employee: employee, certification_type: certification_type, customer: employee.customer)

          controller.load_certification_service(Faker.new(certification))

          params = {
            certification: {
              employee_id: 1,
              certification_type_id: 1
            },
            source: :certification,
            commit: 'Create'
          }

          post :create, params, {}

          response.should redirect_to(certification_type)
        end

        it 'gives successful message on success' do
          employee = create(:employee, first_name: 'Dutch', last_name: 'Barnes')
          certification_type = create(:certification_type, name: 'certType24')
          certification = create(:certification, employee: employee, certification_type: certification_type, customer: employee.customer)

          controller.load_certification_service(Faker.new(certification))

          params = {
            certification: {
              employee_id: 1,
              certification_type_id: 1
            },
            commit: 'Create'
          }

          post :create, params, {}

          flash[:notice].should == "Certification 'certType24' was successfully created for Barnes, Dutch."
        end
      end

      context 'Save and Create Another' do
        it 'calls certification_type_service on success' do
          controller.load_certification_service(Faker.new(build(:certification)))
          fake_certification_type_service = controller.load_certification_type_service(faker_that_returns_empty_list)

          params = {
            employee: {},
            certification: {},
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          fake_certification_type_service.received_message.should == :get_all_certification_types
          fake_certification_type_service.received_params[0].should == current_user
        end

        it 'assigns certification, employees and certification_types on success' do
          controller.load_certification_service(Faker.new(build(:certification)))
          certification_type = create(:certification_type)
          controller.load_certification_type_service(Faker.new([certification_type]))
          employee = create(:employee)
          controller.load_employee_service(Faker.new([employee]))

          params = {
            certification: {
              employee_id: 1,
              certification_type_id: 1
            },
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          assigns(:certification).should be_a(Certification)
          assigns(:certification_types).map(&:model).should eq([certification_type])
          assigns(:employees).map(&:model).should eq([employee])
        end

        it 'renders create certification on success' do
          controller.load_certification_service(Faker.new(build(:certification)))
          controller.load_certification_type_service(Faker.new)

          params = {
            employee: {},
            certification: {},
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          response.should render_template('new')
        end

        it 'gives successful message on success' do
          employee = create(:employee, first_name: 'Dutch', last_name: 'Barnes')
          certification_type = create(:certification_type, name: 'certType24')
          certification = create(:certification, employee: employee, certification_type: certification_type, customer: employee.customer)

          controller.load_certification_service(Faker.new(certification))
          controller.load_certification_type_service(faker_that_returns_empty_list)

          params = {
            certification: {
              employee_id: 1,
              certification_type_id: 1
            },
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          flash[:notice].should == "Certification 'certType24' was successfully created for Barnes, Dutch."
        end
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not call factory' do
        fake_certification_service = controller.load_certification_service(Faker.new)

        post :create, {}, {}

        fake_certification_service.received_message.should be_nil
      end
    end
  end

  describe 'GET #edit' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns the requested certification as @certification' do
        certification = create(:certification, customer: customer)
        get :edit, {:id => certification.to_param}, {}
        assigns(:certification).should eq(certification)
      end

      it 'assigns certification_types' do
        certification = create(:certification, customer: customer)
        controller.load_certification_service(Faker.new)
        certification_type = create(:certification_type)
        controller.load_certification_type_service(Faker.new([certification_type]))

        get :edit, {:id => certification.to_param}, {}

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the requested certification as @certification' do
        certification = create(:certification, customer: customer)
        get :edit, {:id => certification.to_param}, {}
        assigns(:certification).should eq(certification)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certifications' do
        certification = create(:certification, customer: customer)
        get :edit, {:id => certification.to_param}, {}
        assigns(:certification).should be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested certification' do
          certification = create(:certification, customer: customer)
          new_certification_type = create(:certification_type, units_required: 100, customer: customer)
          fake_certification_service = Faker.new(certification)
          controller.load_certification_service(fake_certification_service)

          put :update, {:id => certification.to_param, :certification =>
            {
              'certification_type_id' => new_certification_type.id,
              'trainer' => 'new trainer',
              'units_achieved' => 45,
              'last_certification_date' => '01/01/2001',
              'comments' => 'some new notes'
            }
          }, {}

          fake_certification_service.received_message.should == :update_certification
          fake_certification_service.received_params[0].should == certification
          fake_certification_service.received_params[1][:certification_type_id].should == new_certification_type.id.to_s
          fake_certification_service.received_params[1][:trainer].should == 'new trainer'
          fake_certification_service.received_params[1][:units_achieved].should == '45'
          fake_certification_service.received_params[1][:last_certification_date].should == '01/01/2001'
          fake_certification_service.received_params[1][:comments].should == 'some new notes'
        end

        it 'assigns the requested certification as @certification' do
          controller.load_certification_service(Faker.new(true))
          certification = create(:certification, customer: customer)

          put :update, {:id => certification.to_param, :certification => {'comments' => 'Test'}}, {}

          assigns(:certification).should eq(certification)
        end

        it 'redirects to the show certification type page' do
          controller.load_certification_service(Faker.new(true))
          certification_type = create(:certification_type, name: 'CPR')
          employee = create(:employee, first_name: 'John', last_name: 'Smith')
          certification = create(:certification, certification_type: certification_type, employee: employee, customer: customer)

          put :update, {:id => certification.to_param, :certification => {'comments' => 'Test'}}, {}

          response.should redirect_to(certification.certification_type)
          flash[:notice].should == "Certification 'CPR' was successfully updated for Smith, John."
        end
      end

      describe 'with invalid params' do
        it 'assigns the certification as @certification' do
          controller.load_certification_service(Faker.new(false))
          certification = create(:certification, customer: customer)

          put :update, {:id => certification.to_param, :certification => {'comments' => 'invalid value'}}, {}

          assigns(:certification).should eq(certification)
        end

        it "re-renders the 'edit' template" do
          controller.load_certification_service(Faker.new(false))
          certification = create(:certification, customer: customer)

          put :update, {:id => certification.to_param, :certification => {'comments' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns @certification_types' do
          certification = create(:certification, customer: customer)
          controller.load_certification_service(Faker.new(false))
          certification_type = create(:certification_type)
          controller.load_certification_type_service(Faker.new([certification_type]))

          put :update, {:id => certification.to_param, :certification => {'comments' => 'invalid value'}}, {}

          assigns(:certification_types).map(&:model).should eq([certification_type])
        end

      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'updates the requested certification' do
        fake_certification_service = Faker.new(true)
        controller.load_certification_service(fake_certification_service)
        certification = create(:certification, customer: customer)

        put :update, {:id => certification.to_param, :certification =>
          {
            'inspection_interval' => 'Annually',
            'last_inspection_date' => '01/01/2001',
            'comments' => 'some new notes'
          }
        }, {}

        fake_certification_service.received_message.should == :update_certification
      end

      it 'assigns the requested certification as @certification' do
        certification = create(:certification, customer: customer)
        controller.load_certification_service(Faker.new(certification))

        put :update, {:id => certification.to_param, :certification => {'comments' => 'Test'}}, {}

        assigns(:certification).should eq(certification)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certifications' do
        certification = create(:certification, customer: customer)

        put :update, {:id => certification.to_param, :certification => {'comments' => 'Test'}}, {}

        assigns(:certification).should be_nil
      end
    end
  end

  describe 'GET #show' do
    context 'when certification user' do
      let (:current_user) { stub_certification_user(customer) }

      before do
        sign_in current_user
      end

      it 'assigns certification as @certification' do
        certification = create(:certification, customer: customer)

        get :show, {:id => certification.to_param}, {}

        assigns(:certification).should eq(certification)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns certification as @certification' do
        certification = create(:certification, customer: customer)

        get :show, {:id => certification.to_param}, {}

        assigns(:certification).should eq(certification)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certifications' do
        certification = create(:certification, customer: customer)

        get :show, {:id => certification.to_param}, {}

        assigns(:certification).should be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'calls CertificationService' do
        fake_certification_service = Faker.new
        controller.load_certification_service(fake_certification_service)
        certification = create(:certification, customer: customer)

        delete :destroy, {:id => certification.to_param}, {}

        fake_certification_service.received_message.should == :delete_certification
      end

      it 'redirects to the show certification type page' do
        certification = create(:certification, customer: customer)
        controller.load_certification_service(Faker.new)

        delete :destroy, {:id => certification.to_param}, {}

        response.should redirect_to(certification.certification_type)
      end

      it 'displays the success message' do
        employee = create(:employee, first_name: 'first', last_name: 'last')
        certification_type = create(:certification_type, name: 'CPR')
        certification = create(:certification, employee: employee, certification_type: certification_type, customer: customer)
        controller.load_certification_service(Faker.new)

        delete :destroy, {:id => certification.to_param}, {}

        flash[:notice].should == "Certification 'CPR' was successfully deleted for last, first."
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls CertificationService' do
        fake_certification_service = Faker.new
        controller.load_certification_service(fake_certification_service)
        certification = create(:certification, customer: customer)

        delete :destroy, {:id => certification.to_param}, {}

        fake_certification_service.received_message.should == :delete_certification
      end
    end
  end

  describe 'GET #certification_history' do
    context 'when certification user' do
      let (:current_user) { stub_certification_user(customer) }

      before do
        sign_in current_user
      end

      it 'assigns certification presenter as @certification' do
        certification = create(:certification, customer: customer)
        get :certification_history, {:id => certification.to_param}, {}
        assigns(:certification).should eq(certification)
      end

      it 'assigns certification_periods as @certification_periods' do
        certification_period = create(:certification_period)
        certification = create(:certification, customer: customer, active_certification_period: certification_period)
        get :certification_history, {:id => certification.to_param}, {}
        assigns(:certification_periods).map(&:model).should eq([certification_period])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns certification presenter as @certification' do
        certification = create(:certification, customer: customer)
        get :certification_history, {:id => certification.to_param}, {}
        assigns(:certification).should eq(certification)
      end

      it 'assigns certification_periods as @certification_periods' do
        certification_period = create(:certification_period)
        certification = create(:certification, customer: customer, active_certification_period: certification_period)
        get :certification_history, {:id => certification.to_param}, {}
        assigns(:certification_periods).map(&:model).should eq([certification_period])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certifications presenter as @certification' do
        certification = create(:certification, customer: customer)
        get :certification_history, {:id => certification.to_param}, {}
        assigns(:certification).should be_nil
      end

      it 'does not assign certifications_periods as @certification_periods' do
        certification_period = create(:certification_period)
        certification = create(:certification, customer: customer, active_certification_period: certification_period)
        get :certification_history, {:id => certification.to_param}, {}
        assigns(:certification_periods).should be_nil
      end
    end
  end

  describe 'GET #search' do
    context 'when certification user' do
      before do
        @my_user = stub_certification_user(customer)
        sign_in @my_user
      end

      context 'HTML format' do
        it 'calls get_all_certifications with current_user and params' do
          fake_certification_service = controller.load_certification_service(faker_that_returns_empty_list)
          params = {sort: 'name', direction: 'asc'}
          CertificationListPresenter.stub(:new).and_return(faker_that_returns_empty_list)
          fake_certification_list_presenter = Faker.new([])
          CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)

          get :search, params

          fake_certification_service.received_message.should == :search_certifications
          fake_certification_service.received_params[0].should == @my_user

          fake_certification_list_presenter.received_message.should == :present
          fake_certification_list_presenter.received_params[0]['sort'].should == 'name'
          fake_certification_list_presenter.received_params[0]['direction'].should == 'asc'
        end

        it 'assigns certifications' do
          certification = build(:certification, customer: customer)
          CertificationListPresenter.stub(:new).and_return(Faker.new([CertificationPresenter.new(certification)]))

          get :search

          assigns(:certifications).map(&:model).should eq([certification])
        end

        it 'assigns certifications_count' do
          controller.load_certification_service(Faker.new(big_list_of_certifications))

          get :search, {per_page: 25, page: 1}

          assigns(:certification_count).should eq(30)
        end

        it 'assigns report_title' do
          CertificationListPresenter.stub(:new).and_return(faker_that_returns_empty_list)

          get :search

          assigns(:report_title).should eq('Search Certifications')
        end

        it 'assigns sorted locations' do
          location = build(:location)
          fake_location_list_presenter = Faker.new([location])
          LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
          controller.load_location_service(Faker.new([location]))

          get :search

          fake_location_list_presenter.received_message.should == :sort
          assigns(:locations).should == [location]
        end

        it 'assigns certification types' do
          get :search

          assigns(:certification_types).size.should == 2
          assigns(:certification_types).first.id.should == 'units_based'
          assigns(:certification_types).first.name.should == 'Units Based'
          assigns(:certification_types).last.id.should == 'date_based'
          assigns(:certification_types).last.name.should == 'Date Based'
        end

        it 'sets export_template' do
          controller.load_certification_service(faker_that_returns_empty_list)

          get :search

          assigns(:export_template).should == 'search_certification_export'
        end
      end

      context 'export' do
        subject { controller }
        it_behaves_like 'a controller that exports to csv, xls, and pdf',
                        resource: :certification,
                        load_method: :load_certification_service,
                        get_method: :search_certifications,
                        action: :search,
                        report_title: 'Search Certifications',
                        filename: 'search_certifications'
      end
    end
  end
end