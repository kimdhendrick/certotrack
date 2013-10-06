require 'spec_helper'

describe CertificationTypesController do

  let(:customer) {create(:customer)}

  describe 'GET new' do
    context 'when certification user' do
      let(:customer) {create(:customer)}
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

  describe 'POST create' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'calls CertificationTypeService' do
          CertificationTypeService.any_instance.should_receive(:create_certification_type).once.and_return(build(:certification_type))
          post :create, {:certification_type => certification_type_attributes}, {}
        end

        it 'assigns a newly created certification_type as @certification_type' do
          CertificationTypeService.any_instance.stub(:create_certification_type).and_return(build(:certification_type))
          post :create, {:certification_type => certification_type_attributes}, {}
          assigns(:certification_type).should be_a(CertificationType)
        end

        it 'redirects to the created certification_type' do
          CertificationTypeService.any_instance.stub(:create_certification_type).and_return(create(:certification_type))
          post :create, {:certification_type => certification_type_attributes}, {}
          response.should redirect_to(CertificationType.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved certification_type as @certification_type' do
          CertificationTypeService.any_instance.should_receive(:create_certification_type).once.and_return(build(:certification_type))
          CertificationType.any_instance.stub(:save).and_return(false)

          post :create, {:certification_type => {'name' => 'invalid value'}}, {}

          assigns(:certification_type).should be_a_new(CertificationType)
        end

        it "re-renders the 'new' template" do
          CertificationTypeService.any_instance.should_receive(:create_certification_type).once.and_return(build(:certification_type))
          CertificationType.any_instance.stub(:save).and_return(false)
          post :create, {:certification_type => {'name' => 'invalid value'}}, {}
          response.should render_template('new')
        end

        it 'assigns @intervals' do
          CertificationTypeService.any_instance.should_receive(:create_certification_type).once.and_return(build(:certification_type))
          CertificationType.any_instance.stub(:save).and_return(false)
          post :create, {:certification_type => {'name' => 'invalid value'}}, {}
          assigns(:intervals).should eq(Interval.all.to_a)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls CertificationTypeService' do
        CertificationTypeService.any_instance.should_receive(:create_certification_type).once.and_return(build(:certification_type))
        post :create, {:certification_type => certification_type_attributes}, {}
      end

      it 'assigns a newly created certification_type as @certification_type' do
        CertificationTypeService.any_instance.should_receive(:create_certification_type).once.and_return(build(:certification_type))
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

  describe 'GET edit' do
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
  
  describe 'GET show' do
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

        fake_employee_list_presenter.received_message.should == :present
        fake_employee_list_presenter.received_params[0].should == {}
      end

      it 'assigns certifications as @certifications' do
        certification = create(:certification, customer: customer)
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

        fake_employee_list_presenter.received_message.should == :present
        fake_employee_list_presenter.received_params[0].should == {sort: 'sort_key', direction: 'desc'}
      end

      it 'sorts certifications by employee name' do
        certification = create(:certification, customer: customer)
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

        fake_certification_list_presenter.received_message.should == :present
        fake_certification_list_presenter.received_params[0].should == {sort: 'sort_key', direction: 'desc'}
      end

      it 'sorts certifications by status' do
        certification = create(:certification, customer: customer)
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

        fake_certification_list_presenter.received_message.should == :present
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

  describe 'PUT update' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested certification_type' do
          certification_type = create(:certification_type, customer: customer)
          CertificationTypeService.any_instance.should_receive(:update_certification_type).once

          put :update, {:id => certification_type.to_param, :certification_type =>
            {
              'name' => 'Box',
              'interval' => 'Annually',
              'units_required' => '99'
            }
          }, {}
        end

        it 'assigns the requested certification_type as @certification_type' do
          CertificationTypeService.any_instance.stub(:update_certification_type).and_return(true)
          certification_type = create(:certification_type, customer: customer)
          put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, {}
          assigns(:certification_type).should eq(certification_type)
        end

        it 'redirects to the certification_type' do
          CertificationTypeService.any_instance.stub(:update_certification_type).and_return(true)
          certification_type = create(:certification_type, customer: customer)
          put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, {}
          response.should redirect_to(certification_type)
        end
      end

      describe 'with invalid params' do
        it 'assigns the certification_type as @certification_type' do
          certification_type = create(:certification_type, customer: customer)
          CertificationTypeService.any_instance.stub(:update_certification_type).and_return(false)
          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, {}
          assigns(:certification_type).should eq(certification_type)
        end

        it "re-renders the 'edit' template" do
          certification_type = create(:certification_type, customer: customer)
          CertificationTypeService.any_instance.stub(:update_certification_type).and_return(false)
          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, {}
          response.should render_template('edit')
        end

        it 'assigns @intervals' do
          certification_type = create(:certification_type, customer: customer)
          CertificationTypeService.any_instance.stub(:update_certification_type).and_return(false)
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
        certification_type = create(:certification_type, customer: customer)
        CertificationTypeService.any_instance.should_receive(:update_certification_type).once

        put :update, {:id => certification_type.to_param, :certification_type =>
          {
            'name' => 'Box',
            'interval' => 'Annually',
            'units_required' => 89
          }
        }, {}
      end

      it 'assigns the requested certification_type as @certification_type' do
        certification_type = create(:certification_type, customer: customer)
        CertificationTypeService.any_instance.stub(:update_certification_type).and_return(certification_type)
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

  describe 'DELETE destroy' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'calls CertificationTypeService' do
        certification_type = create(:certification_type, customer: customer)
        CertificationTypeService.any_instance.should_receive(:delete_certification_type).once

        delete :destroy, {:id => certification_type.to_param}, {}
      end

      it 'redirects to the certification_type list' do
        certification_type = create(:certification_type, customer: customer)
        CertificationTypeService.any_instance.should_receive(:delete_certification_type).once

        delete :destroy, {:id => certification_type.to_param}, {}

        response.should redirect_to(certification_types_path)
      end

      it 'gives error message when certifications exists' do
        certification_type = create(:certification_type, customer: customer)
        controller.load_certification_type_service(Faker.new(:certification_exists))

        delete :destroy, {:id => certification_type.to_param}, {}

        response.should redirect_to(certification_type_url)
        flash[:notice].should == 'This Certification Type is assigned to existing Employee(s).  You must uncertify the employee(s) before removing it.'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls certification_typeService' do
        certification_type = create(:certification_type, customer: customer)
        CertificationTypeService.any_instance.should_receive(:delete_certification_type).once

        delete :destroy, {:id => certification_type.to_param}, {}
      end
    end
  end

  describe 'GET index' do
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
        CertificationTypeService.any_instance.stub(:get_all_certification_types).and_return([certification_type])

        get :index

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end

      it 'assigns certification_types_count' do
        CertificationTypeService.any_instance.stub(:get_all_certification_types).and_return([build(:certification_type)])

        get :index

        assigns(:certification_types_count).should eq(1)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns certification_types as @certification_types' do
        certification_type = build(:certification_type)
        CertificationTypeService.any_instance.stub(:get_all_certification_types).and_return([certification_type])

        get :index

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign certification_types as @certification_types' do
          certification_type = build(:certification_type)
          CertificationTypeService.any_instance.stub(:get_all_certification_types).and_return([certification_type])

          get :index

          assigns(:certification_types).should be_nil
        end
      end
    end
  end

  describe 'GET search' do
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

        CertificationTypeService.any_instance.stub(:search_certification_types).and_return([certification_type])

        get :search

        assigns(:certification_types).map(&:model).should eq([certification_type])
      end

      it 'assigns certification_types_count' do
        CertificationTypeService.any_instance.stub(:search_certification_types).and_return([build(:certification_type)])

        get :search

        assigns(:certification_types_count).should eq(1)
      end
    end
  end

  describe 'GET ajax_is_units_based' do
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