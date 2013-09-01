require 'spec_helper'

describe CertificationsController do

  describe 'new' do
    context 'when certification user' do
      before do
        @current_user = stub_certification_user
        sign_in @current_user
        @certification_type = create_certification_type
      end

      it 'calls certification service' do
        controller.load_certification_type_service(FakeService.new())
        employee = create_employee
        certification = create_certification(employee: employee)
        fake_certification_service = controller.load_certification_service(FakeService.new(certification))

        get :new, {employee_id: employee.id}, valid_session

        fake_certification_service.received_message.should == :new_certification
        fake_certification_service.received_params[0].should == employee.id.to_s
      end

      it 'assigns @certification' do
        controller.load_certification_type_service(FakeService.new())
        certification = create_certification
        controller.load_certification_service(FakeService.new(certification))

        get :new, {}, valid_session

        assigns(:certification).should == certification
      end

      it 'calls certification_type_service' do
        controller.load_certification_service(FakeService.new())
        fake_certification_type_service = controller.load_certification_type_service(FakeService.new([]))

        get :new, {}, valid_session

        fake_certification_type_service.received_message.should == :get_all_certification_types
        fake_certification_type_service.received_params[0].should == @current_user
      end

      it 'assigns @certification_types' do
        controller.load_certification_service(FakeService.new())
        certification_type = create_certification_type
        controller.load_certification_type_service(FakeService.new([certification_type]))

        get :new, {}, valid_session

        assigns(:certification_types).should eq([certification_type])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns @certification_types' do
        certification_type = new_certification_type
        controller.load_certification_type_service(FakeService.new([certification_type]))
        controller.load_certification_service(FakeService.new())

        get :new, {}, valid_session

        assigns(:certification_types).should eq([certification_type])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign @certification_types' do
        get :new, {}, valid_session
        assigns(:certification_types).should be_nil
      end
    end
  end

  describe 'create' do
    context 'when certification user' do
      before do
        @current_user = stub_certification_user
        sign_in @current_user
      end

      it 'calls creates certification using CertificationService' do
        Certification.any_instance.stub(:valid?).and_return(true)
        fake_certification_service = controller.load_certification_service(FakeService.new(new_certification))

        params = {
          employee: {id: 99},
          certification: {
            certification_type_id: 1001,
            last_certification_date: Date.new(2003, 3, 3),
            trainer: 'John Jacob Jingle',
            comments: 'my name too'
          },
          commit: "Create"
        }

        post :create, params, valid_session

        fake_certification_service.received_message.should == :certify
        fake_certification_service.received_params[0].should == "99"
        fake_certification_service.received_params[1].should == "1001"
        fake_certification_service.received_params[2].should == "2003-03-03"
        fake_certification_service.received_params[3].should == 'John Jacob Jingle'
        fake_certification_service.received_params[4].should == 'my name too'
      end

      it 're-renders new on error' do
        controller.load_certification_type_service(FakeService.new())
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(new_certification))

        post :create, {employee: {}, certification: {}}, valid_session

        response.should render_template('new')
      end

      it 'assigns @certification on error' do
        controller.load_certification_type_service(FakeService.new())
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(new_certification))

        get :create, {employee: {}, certification: {}}, valid_session

        assigns(:certification).should be_a(Certification)
      end

      it 'calls certification_type_service on error' do
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(new_certification))

        certification_type = create_certification_type
        fake_certification_type_service = controller.load_certification_type_service(FakeService.new([certification_type]))

        get :create, {employee: {}, certification: {}}, valid_session

        fake_certification_type_service.received_message.should == :get_all_certification_types
        fake_certification_type_service.received_params[0].should == @current_user
      end

      it 'assigns @certification_types on error' do
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(new_certification))

        certification_type = create_certification_type
        controller.load_certification_type_service(FakeService.new([certification_type]))

        get :create, {employee: {}, certification: {}}, valid_session

        assigns(:certification_types).should eq([certification_type])
      end

      context 'Create' do
        it 'redirects to show employee on success' do
          employee = create_employee
          certification_type = create_certification_type
          certification = create_certification(employee: employee, certification_type: certification_type)

          controller.load_certification_service(FakeService.new(certification))

          params = {
            employee: {},
            certification: {},
            commit: 'Create'
          }

          post :create, params, valid_session

          response.should redirect_to(employee)
        end

        it 'gives successful message on success' do
          employee = create_employee(first_name: 'Dutch', last_name: 'Barnes')
          certification_type = create_certification_type(name: 'certType24')
          certification = create_certification(employee: employee, certification_type: certification_type)

          controller.load_certification_service(FakeService.new(certification))

          params = {
            employee: {},
            certification: {},
            commit: 'Create'
          }

          post :create, params, valid_session

          flash[:notice].should == "Certification: certType24 created for Barnes, Dutch."
        end
      end

      context 'Save and Create Another' do
        it 'calls certification_type_service on success' do
          controller.load_certification_service(FakeService.new(new_certification))
          fake_certification_type_service = controller.load_certification_type_service(FakeService.new([]))

          params = {
            employee: {},
            certification: {},
            commit: 'Save and Create Another'
          }

          post :create, params, valid_session

          fake_certification_type_service.received_message.should == :get_all_certification_types
          fake_certification_type_service.received_params[0].should == @current_user
        end

        it 'assigns certification and certification_types on success' do
          controller.load_certification_service(FakeService.new(new_certification))
          certification_type = create_certification_type
          controller.load_certification_type_service(FakeService.new([certification_type]))

          params = {
            employee: {},
            certification: {},
            commit: 'Save and Create Another'
          }

          post :create, params, valid_session

          assigns(:certification).should be_a(Certification)
          assigns(:certification_types).should eq([certification_type])
        end

        it 'renders create certification on success' do
          controller.load_certification_service(FakeService.new(new_certification))
          controller.load_certification_type_service(FakeService.new())

          params = {
            employee: {},
            certification: {},
            commit: 'Save and Create Another'
          }

          post :create, params, valid_session

          response.should render_template('new')
        end

        it 'gives successful message on success' do
          employee = create_employee(first_name: 'Dutch', last_name: 'Barnes')
          certification_type = create_certification_type(name: 'certType24')
          certification = create_certification(employee: employee, certification_type: certification_type)

          controller.load_certification_service(FakeService.new(certification))
          controller.load_certification_type_service(FakeService.new([]))

          params = {
            employee: {},
            certification: {},
            commit: 'Save and Create Another'
          }

          post :create, params, valid_session

          flash[:notice].should == "Certification: certType24 created for Barnes, Dutch."
        end
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not call factory' do
        fake_certification_service = controller.load_certification_service(FakeService.new())

        post :create, {}, valid_session

        fake_certification_service.received_message.should be_nil
      end
    end
  end
end
