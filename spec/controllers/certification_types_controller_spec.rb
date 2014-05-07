require 'spec_helper'

describe CertificationTypesController do

  let(:customer) { create(:customer) }
  let(:fake_certification_type_service_persisted) { Faker.new(create(:certification_type, name: 'CPR')) }
  let(:fake_certification_type_service_non_persisted) { Faker.new(CertificationType.new) }

  describe 'GET #new' do
    context 'when certification user' do
      let(:customer) { create(:customer) }
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns a new certification type as @certification_type' do
        get :new, {}, {}
        assigns(:certification_type).should be_a_new(CertificationType)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns a new certification_type as @certification_type' do
        get :new, {}, {}
        assigns(:certification_type).should be_a_new(CertificationType)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        get :new, {}, {}
        assigns(:certification_type).should be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'calls certification_type_service' do
          controller.load_certification_type_service(fake_certification_type_service_persisted)

          post :create, {:certification_type => certification_type_attributes}, {}

          fake_certification_type_service_persisted.received_message.should == :create_certification_type
        end

        it 'assigns a newly created certification_type as @certification_type' do
          controller.load_certification_type_service(fake_certification_type_service_persisted)

          post :create, {:certification_type => certification_type_attributes}, {}

          assigns(:certification_type).should be_a(CertificationType)
        end

        it 'redirects to the created certification_type' do
          controller.load_certification_type_service(fake_certification_type_service_persisted)

          post :create, {:certification_type => certification_type_attributes}, {}

          response.should redirect_to(CertificationType.last)
          flash[:notice].should == "Certification Type 'CPR' was successfully created."
        end

        it 'sets the current user as the creator' do
          controller.load_certification_type_service(fake_certification_type_service_persisted)

          post :create, {:certification_type => certification_type_attributes}, {}

          fake_certification_type_service_persisted.received_params[1]['created_by'].should =~ /username/
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved certification_type as @certification_type' do
          controller.load_certification_type_service(fake_certification_type_service_non_persisted)

          post :create, {:certification_type => {'name' => 'invalid value'}}, {}

          assigns(:certification_type).should be_a_new(CertificationType)
        end

        it "re-renders the 'new' template" do
          controller.load_certification_type_service(fake_certification_type_service_non_persisted)

          post :create, {:certification_type => {'name' => 'invalid value'}}, {}

          response.should render_template('new')
        end

        it 'assigns @intervals' do
          controller.load_certification_type_service(fake_certification_type_service_non_persisted)

          post :create, {:certification_type => {'name' => 'invalid value'}}, {}

          assigns(:intervals).should eq(Interval.all.to_a)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls certification_type_service' do
        controller.load_certification_type_service(fake_certification_type_service_non_persisted)

        post :create, {:certification_type => certification_type_attributes}, {}

        fake_certification_type_service_non_persisted.received_message.should == :create_certification_type
      end

      it 'assigns a newly created certification_type as @certification_type' do
        controller.load_certification_type_service(fake_certification_type_service_non_persisted)

        post :create, {:certification_type => certification_type_attributes}, {}

        assigns(:certification_type).should be_a(CertificationType)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        expect {
          post :create, {:certification_type => certification_type_attributes}, {}
        }.not_to change(CertificationType, :count)

        assigns(:certification_type).should be_nil
      end
    end
  end

  describe 'GET #show' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        get :show, {:id => certification_type.to_param}, {}
        assigns(:certification_type).should eq(certification_type)
      end

      it 'assigns non_certified_employees as @non_certified_employees' do
        employee = create(:employee, customer: customer)
        fake_employee_service = controller.load_employee_service(Faker.new([employee]))
        certification_type = create(:certification_type, customer: customer)
        fake_employee_list_presenter = Faker.new([EmployeePresenter.new(employee)])
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(fake_employee_list_presenter)

        get :show, {id: certification_type.id}, {}

        assigns(:non_certified_employees).map(&:model).should eq([employee])
        assigns(:non_certified_employee_count).should == 1
        fake_employee_service.received_message.should == :get_employees_not_certified_for
        fake_employee_service.received_params[0].should == certification_type

        fake_employee_list_presenter.received_message.should == :sort
        fake_employee_list_presenter.received_params[0].should == {}
      end

      it 'assigns certifications as @certifications' do
        certification = create(:certification)
        fake_certification_service = controller.load_certification_service(Faker.new([certification]))
        certification_type = create(:certification_type, customer: customer)
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        get :show, {id: certification_type.id}, {}

        assigns(:certifications).map(&:model).should eq([certification])
        assigns(:certifications_count).should == 1
        fake_certification_service.received_message.should == :get_all_certifications_for_certification_type
        fake_certification_service.received_params[0].should == certification_type
      end

      it 'sorts non_certified_employees by employee name' do
        employee = create(:employee, customer: customer)
        fake_employee_service = controller.load_employee_service(Faker.new([employee]))
        certification_type = create(:certification_type, customer: customer)

        fake_employee_list_presenter = Faker.new([employee])
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(fake_employee_list_presenter)

        params = {
          id: certification_type.id,
          sort: 'sort_key',
          direction: 'desc',
          options: 'non_certified_employee_name'
        }

        get :show, params, {}

        fake_employee_service.received_message.should == :get_employees_not_certified_for
        fake_employee_service.received_params[0].should == certification_type

        fake_employee_list_presenter.received_message.should == :sort
        fake_employee_list_presenter.received_params[0].should == {sort: 'sort_key', direction: 'desc'}
      end

      it 'sorts certifications by employee name' do
        certification = create(:certification)
        fake_certification_service = controller.load_certification_service(Faker.new([certification]))
        certification_type = create(:certification_type, customer: customer)
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        fake_certification_list_presenter = Faker.new([certification])
        #noinspection RubyArgCount
        CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)

        params = {
          id: certification_type.id,
          sort: 'sort_key',
          direction: 'desc',
          options: 'certified_employee_name'
        }

        get :show, params, {}

        fake_certification_service.received_message.should == :get_all_certifications_for_certification_type

        fake_certification_list_presenter.received_message.should == :sort
        fake_certification_list_presenter.received_params[0].should == {sort: 'sort_key', direction: 'desc'}
      end

      it 'sorts certifications by status' do
        certification = create(:certification)
        fake_certification_service = controller.load_certification_service(Faker.new([certification]))
        certification_type = create(:certification_type, customer: customer)
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        fake_certification_list_presenter = Faker.new([certification])
        #noinspection RubyArgCount
        CertificationListPresenter.stub(:new).and_return(fake_certification_list_presenter)

        params = {
          id: certification_type.id,
          sort: 'sort_key',
          direction: 'desc',
          options: 'certified_status'
        }

        get :show, params, {}

        fake_certification_service.received_message.should == :get_all_certifications_for_certification_type

        fake_certification_list_presenter.received_message.should == :sort
        fake_certification_list_presenter.received_params[0].should == {sort: 'status_code', direction: 'desc'}
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        get :show, {:id => certification_type.to_param}, {}
        assigns(:certification_type).should eq(certification_type)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)
        get :show, {:id => certification_type.to_param}, {}
        assigns(:certification_type).should be_nil
      end
    end
  end

  describe 'GET #edit' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns the requested certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)
        get :edit, {:id => certification_type.to_param}, {}
        assigns(:certification_type).should eq(certification_type)
      end

      it 'assigns @intervals' do
        certification_type = create(:certification_type, customer: customer)
        get :edit, {:id => certification_type.to_param}, {}
        assigns(:intervals).should eq(Interval.all.to_a)
      end

    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns the requested certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)
        get :edit, {:id => certification_type.to_param}, {}
        assigns(:certification_type).should eq(certification_type)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)
        get :edit, {:id => certification_type.to_param}, {}
        assigns(:certification_type).should be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested certification_type' do
          certification_type = create(:certification_type, customer: customer)
          controller.load_certification_type_service(fake_certification_type_service_non_persisted)

          put :update, {:id => certification_type.to_param, :certification_type =>
            {
              'name' => 'Box',
              'interval' => 'Annually',
              'units_required' => '99'
            }
          }, {}

          fake_certification_type_service_non_persisted.received_message.should == :update_certification_type
        end

        it 'assigns the requested certification_type as @certification_type' do
          controller.load_certification_type_service(fake_certification_type_service_non_persisted)
          certification_type = create(:certification_type, customer: customer)

          put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, {}

          assigns(:certification_type).should eq(certification_type)
        end

        it 'redirects to the certification_type' do
          controller.load_certification_type_service(fake_certification_type_service_non_persisted)
          certification_type = create(:certification_type, name: 'CPR', customer: customer)

          put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, {}

          response.should redirect_to(certification_type)
          flash[:notice].should == "Certification Type 'CPR' was successfully updated."
        end
      end

      describe 'with invalid params' do
        it 'assigns the certification_type as @certification_type' do
          controller.load_certification_type_service(fake_certification_type_service_non_persisted)
          certification_type = create(:certification_type, customer: customer)

          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, {}

          assigns(:certification_type).should eq(certification_type)
        end

        it "re-renders the 'edit' template" do
          controller.load_certification_type_service(Faker.new(false))
          certification_type = create(:certification_type, customer: customer)

          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns @intervals' do
          controller.load_certification_type_service(Faker.new(false))
          certification_type = create(:certification_type, customer: customer)

          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, {}

          assigns(:intervals).should eq(Interval.all.to_a)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'updates the requested certification_type' do
        controller.load_certification_type_service(fake_certification_type_service_non_persisted)
        certification_type = create(:certification_type, customer: customer)

        put :update, {:id => certification_type.to_param, :certification_type =>
          {
            'name' => 'Box',
            'interval' => 'Annually',
            'units_required' => 89
          }
        }, {}

        fake_certification_type_service_non_persisted.received_message.should == :update_certification_type
      end

      it 'assigns the requested certification_type as @certification_type' do
        controller.load_certification_type_service(fake_certification_type_service_non_persisted)
        certification_type = create(:certification_type, customer: customer)

        put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, {}

        assigns(:certification_type).should eq(certification_type)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)

        put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, {}

        assigns(:certification_type).should be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user(customer)
      end

      context 'when destroy call succeeds' do
        let(:certification_type) { create(:certification_type, name: 'CPR', customer: customer) }
        let(:fake_certification_type_service) { Faker.new(true) }

        before do
          controller.load_certification_type_service(fake_certification_type_service)
        end

        it 'calls certification_type_service' do
          delete :destroy, {:id => certification_type.to_param}, {}

          fake_certification_type_service.received_message.should == :delete_certification_type
        end

        it 'redirects to the certification_type list' do
          delete :destroy, {:id => certification_type.to_param}, {}

          response.should redirect_to(certification_types_path)
          flash[:notice].should == "Certification Type 'CPR' was successfully deleted."
        end
      end

      context 'when destroy call fails' do
        before do
          certification_type = create(:certification_type, customer: customer)
          certification_type_service = double('certification_type_service')
          certification_type_service.stub(:delete_certification_type).and_return(false)

          certification_service = double('certification_service')
          certification_service.stub(:get_all_certifications_for_certification_type).and_return([])

          employee_service = double('employee_service')
          employee_service.stub(:get_employees_not_certified_for).and_return([])

          controller.load_certification_type_service(certification_type_service)
          controller.load_certification_type_service(certification_service)
          controller.load_certification_type_service(employee_service)

          delete :destroy, {id: certification_type.to_param}, {}
        end

        it 'should render show page' do
          response.should render_template('show')
        end

        it 'should assign @certifications' do
          expect(assigns(:certifications)).to eq([])
        end

        it 'should assign @certifications_count' do
          expect(assigns(:certifications_count)).to eq(0)
        end

        it 'should assign @non_certified_employees' do
          expect(assigns(:non_certified_employees)).to eq([])
        end

        it 'should assign @non_certified_employees_count' do
          expect(assigns(:non_certified_employee_count)).to eq(0)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls certification_type_service' do
        controller.load_certification_type_service(fake_certification_type_service_non_persisted)
        certification_type = create(:certification_type, customer: customer)

        delete :destroy, {:id => certification_type.to_param}, {}

        fake_certification_type_service_non_persisted.received_message.should == :delete_certification_type
      end
    end
  end

  describe 'GET #index' do
    let(:big_list_of_certification_types) do
      big_list_of_certification_types = []
      30.times do
        big_list_of_certification_types << create(:certification_type)
      end
      big_list_of_certification_types
    end

    it 'calls get_all_certification_types with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_certification_type_service = controller.load_certification_type_service(Faker.new([]))
      params = {sort: 'name', direction: 'asc'}

      fake_certification_type_list_presenter = Faker.new([])
      #noinspection RubyArgCount
      CertificationTypeListPresenter.stub(:new).and_return(fake_certification_type_list_presenter)

      get :index, params

      fake_certification_type_service.received_messages.should == [:get_all_certification_types]
      fake_certification_type_service.received_params[0].should == my_user

      fake_certification_type_list_presenter.received_message.should == :present
      fake_certification_type_list_presenter.received_params[0][:sort].should == 'name'
      fake_certification_type_list_presenter.received_params[0][:direction].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns certification_types as @certification_types' do
        certification_type = build(:certification_type)
        fake_certification_type_service = Faker.new([certification_type])
        controller.load_certification_type_service(fake_certification_type_service)

        get :index

        assigns(:certification_types).map(&:model).should eq([certification_type])
        fake_certification_type_service.received_message.should == :get_all_certification_types
      end

      it 'assigns certification_types_count' do
        controller.load_certification_type_service(Faker.new(big_list_of_certification_types))

        get :index, {per_page: 25, page: 1}

        assigns(:certification_types_count).should eq(30)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns certification_types as @certification_types' do
        certification_type = build(:certification_type)
        controller.load_certification_type_service(Faker.new([certification_type]))

        get :index

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET #index' do
        it 'does not assign certification_types as @certification_types' do
          get :index

          assigns(:certification_types).should be_nil
        end
      end
    end
  end

  describe 'GET #search' do
    let(:big_list_of_certification_types) do
      big_list_of_certification_types = []
      30.times do
        big_list_of_certification_types << create(:certification_type)
      end
      big_list_of_certification_types
    end

    it 'calls search_certification_types with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_certification_type_service = controller.load_certification_type_service(Faker.new([]))
      params = {sort: 'name', direction: 'asc'}

      fake_certification_type_list_presenter = Faker.new([])
      #noinspection RubyArgCount
      CertificationTypeListPresenter.stub(:new).and_return(fake_certification_type_list_presenter)

      get :search, params

      fake_certification_type_service.received_messages.should == [:search_certification_types]
      fake_certification_type_service.received_params[0].should == my_user

      fake_certification_type_list_presenter.received_message.should == :present
      fake_certification_type_list_presenter.received_params[0][:sort].should == 'name'
      fake_certification_type_list_presenter.received_params[0][:direction].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns certification_types as @certification_types' do
        certification_type = build(:certification_type, customer: customer)
        controller.load_certification_type_service(Faker.new([certification_type]))

        get :search

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end

      it 'assigns certification_types_count' do
        controller.load_certification_type_service(Faker.new(big_list_of_certification_types))

        get :search, {per_page: 25, page: 1}

        assigns(:certification_types_count).should eq(30)
      end
    end
  end

  describe 'GET #ajax_is_units_based' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'should return true when certification type is units based' do
        certification_type = create(:certification_type, units_required: 1)

        get :ajax_is_units_based, {certification_type_id: certification_type.id}

        json = JSON.parse(response.body)
        json.should == {'is_units_based' => true}
      end

      it 'should return false when certification type is not units based' do
        certification_type = create(:certification_type)

        get :ajax_is_units_based, {certification_type_id: certification_type.id}

        json = JSON.parse(response.body)
        json.should == {'is_units_based' => false}
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'should redirect, I suppose' do
        get :ajax_is_units_based, {certification_type_id: nil}
        response.body.should eq("<html><body>You are being <a href=\"http://test.host/\">redirected</a>.</body></html>")
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'should return true when certification type is units based' do
        certification_type = create(:certification_type, units_required: 1)

        get :ajax_is_units_based, {certification_type_id: certification_type.id}

        json = JSON.parse(response.body)
        json.should == {'is_units_based' => true}
      end

      it 'should return false when certification type is not units based' do
        certification_type = create(:certification_type)

        get :ajax_is_units_based, {certification_type_id: certification_type.id}

        json = JSON.parse(response.body)
        json.should == {'is_units_based' => false}
      end
    end
  end

  def certification_type_attributes
    {
      name: 'Routine Inspection',
      interval: Interval::ONE_YEAR.text
    }
  end
end