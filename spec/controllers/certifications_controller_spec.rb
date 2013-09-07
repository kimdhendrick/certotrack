require 'spec_helper'

describe CertificationsController do

  describe 'new' do
    context 'when certification user' do
      before do
        @current_user = stub_certification_user
        sign_in @current_user
        @certification_type = create(:certification_type)
      end

      it 'calls certification service' do
        controller.load_certification_type_service(FakeService.new())
        employee = create(:employee)
        certification = create(:certification, employee: employee)
        fake_certification_service = controller.load_certification_service(FakeService.new(certification))

        get :new, {employee_id: employee.id}, {}

        fake_certification_service.received_message.should == :new_certification
        fake_certification_service.received_params[0].should == employee.id.to_s
      end

      it 'assigns @certification' do
        controller.load_certification_type_service(FakeService.new())
        certification = create(:certification)
        controller.load_certification_service(FakeService.new(certification))

        get :new, {}, {}

        assigns(:certification).should == certification
      end

      it 'calls certification_type_service' do
        controller.load_certification_service(FakeService.new())
        fake_certification_type_service = controller.load_certification_type_service(FakeService.new([]))

        get :new, {}, {}

        fake_certification_type_service.received_message.should == :get_all_certification_types
        fake_certification_type_service.received_params[0].should == @current_user
      end

      it 'assigns @certification_types' do
        controller.load_certification_service(FakeService.new())
        certification_type = create(:certification_type)
        controller.load_certification_type_service(FakeService.new([certification_type]))

        get :new, {}, {}

        assigns(:certification_types).should eq([certification_type])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns @certification_types' do
        certification_type = build(:certification_type)
        controller.load_certification_type_service(FakeService.new([certification_type]))
        controller.load_certification_service(FakeService.new())

        get :new, {}, {}

        assigns(:certification_types).should eq([certification_type])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign @certification_types' do
        get :new, {}, {}
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
        fake_certification_service = controller.load_certification_service(FakeService.new(build(:certification)))

        params = {
          employee: {id: 99},
          certification: {
            certification_type_id: 1001,
            last_certification_date: '3/3/2003',
            trainer: 'John Jacob Jingle',
            comments: 'my name too'
          },
          commit: "Create"
        }

        post :create, params, {}

        fake_certification_service.received_message.should == :certify
        fake_certification_service.received_params[0].should == '99'
        fake_certification_service.received_params[1].should == '1001'
        fake_certification_service.received_params[2].should == '3/3/2003'
        fake_certification_service.received_params[3].should == 'John Jacob Jingle'
        fake_certification_service.received_params[4].should == 'my name too'
      end

      it 're-renders new on error' do
        controller.load_certification_type_service(FakeService.new())
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(build(:certification)))

        post :create, {employee: {}, certification: {}}, {}

        response.should render_template('new')
      end

      it 'assigns @certification on error' do
        controller.load_certification_type_service(FakeService.new())
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(build(:certification)))

        get :create, {employee: {}, certification: {certification_type_id: 1}}, {}

        assigns(:certification).should be_a(Certification)
      end

      it 'calls certification_type_service on error' do
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(build(:certification)))

        certification_type = create(:certification_type)
        fake_certification_type_service = controller.load_certification_type_service(FakeService.new([certification_type]))

        get :create, {employee: {}, certification: {}}, {}

        fake_certification_type_service.received_message.should == :get_all_certification_types
        fake_certification_type_service.received_params[0].should == @current_user
      end

      it 'assigns @certification_types on error' do
        Certification.any_instance.stub(:valid?).and_return(false)
        controller.load_certification_service(FakeService.new(build(:certification)))

        certification_type = create(:certification_type)
        controller.load_certification_type_service(FakeService.new([certification_type]))

        get :create, {employee: {}, certification: {}}, {}

        assigns(:certification_types).should eq([certification_type])
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
        it 'redirects to show employee on success' do
          employee = create(:employee)
          certification_type = create(:certification_type)
          certification = create(:certification, employee: employee, certification_type: certification_type)

          controller.load_certification_service(FakeService.new(certification))

          params = {
            employee: {},
            certification: {certification_type_id: 1},
            commit: 'Create'
          }

          post :create, params, {}

          response.should redirect_to(employee)
        end

        it 'gives successful message on success' do
          employee = create(:employee, first_name: 'Dutch', last_name: 'Barnes')
          certification_type = create(:certification_type, name: 'certType24')
          certification = create(:certification, employee: employee, certification_type: certification_type)

          controller.load_certification_service(FakeService.new(certification))

          params = {
            employee: {},
            certification: {certification_type_id: 1},
            commit: 'Create'
          }

          post :create, params, {}

          flash[:notice].should == "Certification: certType24 created for Barnes, Dutch."
        end
      end

      context 'Save and Create Another' do
        it 'calls certification_type_service on success' do
          controller.load_certification_service(FakeService.new(build(:certification)))
          fake_certification_type_service = controller.load_certification_type_service(FakeService.new([]))

          params = {
            employee: {},
            certification: {},
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          fake_certification_type_service.received_message.should == :get_all_certification_types
          fake_certification_type_service.received_params[0].should == @current_user
        end

        it 'assigns certification and certification_types on success' do
          controller.load_certification_service(FakeService.new(build(:certification)))
          certification_type = create(:certification_type)
          controller.load_certification_type_service(FakeService.new([certification_type]))

          params = {
            employee: {},
            certification: {certification_type_id: 1},
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          assigns(:certification).should be_a(Certification)
          assigns(:certification_types).should eq([certification_type])
        end

        it 'renders create certification on success' do
          controller.load_certification_service(FakeService.new(build(:certification)))
          controller.load_certification_type_service(FakeService.new())

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
          certification = create(:certification, employee: employee, certification_type: certification_type)

          controller.load_certification_service(FakeService.new(certification))
          controller.load_certification_type_service(FakeService.new([]))

          params = {
            employee: {},
            certification: {certification_type_id: 1},
            commit: 'Save and Create Another'
          }

          post :create, params, {}

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

        post :create, {}, {}

        fake_certification_service.received_message.should be_nil
      end
    end
  end
end
