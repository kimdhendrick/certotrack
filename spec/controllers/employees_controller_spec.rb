require 'spec_helper'

describe EmployeesController do
  let(:customer) { create(:customer) }

  describe 'GET #new' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns a new employee as @employee' do
        get :new, {}, {}

        assigns(:employee).should be_a_new(Employee)
      end

      it 'assigns sorted locations' do
        location = build(:location)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        controller.load_location_service(Faker.new([location]))

        get :new

        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns a new employee as @employee' do
        get :new, {}, {}
        assigns(:employee).should be_a_new(Employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        get :new, {}, {}
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'creates a new employee' do
          fake_employee_service = Faker.new(create(:employee))
          controller.load_employee_service(fake_employee_service)

          post :create, {:employee => employee_attributes}, {}

          fake_employee_service.received_message.should == :create_employee
        end

        it 'assigns a newly created employee as @employee' do
          controller.load_employee_service(Faker.new(create(:employee)))

          post :create, {:employee => employee_attributes}, {}

          assigns(:employee).should be_a(Employee)
        end

        it 'redirects to the created employee' do
          controller.load_employee_service(Faker.new(create(:employee)))

          post :create, {:employee => employee_attributes}, {}

          response.should redirect_to(Employee.last)
          flash[:notice].should == 'Employee was successfully created.'
        end

        it 'sets the current_user as the creator' do
          fake_employee_service = Faker.new(build(:employee))
          controller.load_employee_service(fake_employee_service)

          post :create, {:employee => employee_attributes}, {}

          fake_employee_service.received_params[1]['created_by'].should =~ /username/
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved employee as @employee' do
          fake_employee_service = Faker.new(build(:employee))
          controller.load_employee_service(fake_employee_service)

          post :create, {:employee => {'name' => 'invalid value'}}, {}

          assigns(:employee).should be_a_new(Employee)
          fake_employee_service.received_message.should == :create_employee
        end

        it "re-renders the 'new' template" do
          controller.load_employee_service(Faker.new(build(:employee)))

          post :create, {:employee => {'name' => 'invalid value'}}, {}

          response.should render_template('new')
        end

        it 'assigns sorted locations' do
          controller.load_employee_service(Faker.new(build(:employee)))
          location = build(:location)
          fake_location_list_presenter = Faker.new([location])
          LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
          controller.load_location_service(Faker.new([location]))

          post :create, {:employee => {'name' => 'invalid value'}}, {}

          assigns(:locations).should == [location]
          fake_location_list_presenter.received_message.should == :sort
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls EmployeesService' do
        fake_employee_service = Faker.new(build(:employee))
        controller.load_employee_service(fake_employee_service)

        post :create, {:employee => employee_attributes}, {}

        fake_employee_service.received_message.should == :create_employee
      end

      it 'assigns a newly created employee as @employee' do
        controller.load_employee_service(Faker.new(build(:employee)))

        post :create, {:employee => employee_attributes}, {}

        assigns(:employee).should be_a(Employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        expect {
          post :create, {:employee => employee_attributes}, {}
        }.not_to change(Employee, :count)
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'GET #index' do
    let(:big_list_of_employees) do
      big_list_of_employees = []
      30.times do
        big_list_of_employees << create(:employee)
      end
      big_list_of_employees
    end

    it 'calls get_all_employees with current_user' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_employee_service = controller.load_employee_service(Faker.new([]))
      fake_employee_list_presenter = Faker.new([])
      EmployeeListPresenter.stub(:new).and_return(fake_employee_list_presenter)

      get :index, {sort: 'name', direction: 'asc'}

      fake_employee_service.received_message.should == :get_all_employees
      fake_employee_service.received_params[0].should == my_user

      fake_employee_list_presenter.received_message.should == :present
      fake_employee_list_presenter.received_params[0]['sort'].should == 'name'
      fake_employee_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns @employees' do
        employee = build(:employee)
        controller.load_employee_service(Faker.new([employee]))

        get :index

        assigns(:employees).map(&:model).should eq([employee])
      end

      it 'assigns @employee_count' do
        controller.load_employee_service(Faker.new(big_list_of_employees))

        get :index, {per_page: 25, page: 1}

        assigns(:employee_count).should eq(30)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns employee' do
        employee = build(:employee)
        controller.load_employee_service(Faker.new([employee]))

        get :index

        assigns(:employees).map(&:model).should eq([employee])
      end

      it 'assigns employee_count' do
        controller.load_employee_service(Faker.new(big_list_of_employees))

        get :index, {per_page: 25, page: 1}

        assigns(:employee_count).should eq(30)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign employee as @employee' do
          employee = build(:employee)
          controller.load_employee_service(Faker.new([employee]))

          get :index

          assigns(:employees).should be_nil
          assigns(:employee_count).should be_nil
        end
      end
    end
  end

  describe 'GET #show' do
    let(:employee) { create(:employee, customer: customer) }
    let(:certification_service) { double('certification_service') }
    let(:certification) { create(:certification, employee: employee, customer: employee.customer) }
    let(:certifications) { [certification] }

    before do
      controller.load_certification_service(certification_service)
      certification_service.stub(:get_all_certifications_for_employee).and_return(certifications)
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      context 'HTML format' do
        it 'assigns employee as @employee' do
          get :show, {:id => employee.to_param}, {}
          assigns(:employee).should eq(employee)
        end

        it 'assigns certifications as @certifications' do
          get :show, {id: employee.to_param}, {}
          assigns(:certifications).map(&:model).should == certifications
        end
      end

      context 'CSV export' do
        it 'responds to csv format' do
          get :show, {format: 'csv', :id => employee.to_param}, {}

          response.headers['Content-Type'].should == 'text/csv; charset=utf-8'
          response.body.split("\n").count.should == 2
        end

        it 'calls CsvPresenter#present with certifications' do
          fake_csv_presenter = Faker.new
          CsvPresenter.should_receive(:new).with(certifications).and_return(fake_csv_presenter)

          get :show, {format: 'csv', :id => employee.to_param}, {}

          fake_csv_presenter.received_message.should == :present
        end

        it 'exports to file' do
          get :show, {format: 'csv', :id => employee.to_param}, {}

          response.headers['Content-Disposition'].should == 'attachment; filename="employee_certifications.csv"'
        end
      end

      context 'XLS export' do
        it 'responds to xls format' do
          get :show, {format: 'xls', :id => employee.to_param}, {}

          response.headers['Content-Type'].should == 'application/vnd.ms-excel'
        end

        it 'calls ExcelPresenter#present with certifications' do
          fake_xls_presenter = Faker.new
          ExcelPresenter.should_receive(:new).with(certifications, 'Employee Certifications').and_return(fake_xls_presenter)

          get :show, {format: 'xls', :id => employee.to_param}, {}

          fake_xls_presenter.received_message.should == :present
        end

        it 'exports to file' do
          get :show, {format: 'xls', :id => employee.to_param}, {}

          response.headers['Content-Disposition'].should == 'attachment; filename="employee_certifications.xls"'
        end
      end

      context 'PDF export' do
        it 'responds to pdf format' do
          get :show, {format: 'pdf', :id => employee.to_param}, {}

          response.headers['Content-Type'].should == 'application/pdf'
        end

        it 'calls PdfPresenter#present with certifications' do
          fake_pdf_presenter = Faker.new
          sort_params = {'sort' => 'name', 'direction' => 'asc'}
          PdfPresenter.should_receive(:new).with(certifications, 'Employee Certifications', sort_params).and_return(fake_pdf_presenter)

          get :show, {format: 'pdf', :id => employee.to_param}.merge(sort_params), {}

          fake_pdf_presenter.received_message.should == :present
        end

        it 'exports to file' do
          get :show, {format: 'pdf', :id => employee.to_param}, {}

          response.headers['Content-Disposition'].should == 'attachment; filename="employee_certifications.pdf"'
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns employee as @employee' do
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns certifications as @certifications' do
        get :show, {id: employee.to_param}, {}
        assigns(:certifications).map(&:model).should == certifications
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create(:employee, customer: customer)
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'GET #edit' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns the requested employee as @employee' do
        employee = create(:employee, customer: customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns sorted locations' do
        location = build(:location)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        controller.load_location_service(Faker.new([location]))

        get :new

        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns the requested employee as @employee' do
        employee = create(:employee, customer: customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create(:employee, customer: customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested employee' do
          employee = create(:employee, customer: customer)
          fake_employee_service = controller.load_employee_service(Faker.new([]))

          put :update, {:id => employee.to_param, :employee =>
            {
              'first_name' => 'Susie',
              'last_name' => 'Sampson',
              'employee_number' => 'newEmpNum',
              'location_id' => 1,
            }
          }, {}

          fake_employee_service.received_messages.should == [:update_employee]
        end

        it 'assigns the requested employee as @employee' do
          employee = create(:employee, customer: customer)
          fake_employee_service = controller.load_employee_service(Faker.new(true))

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          assigns(:employee).should eq(employee)
          fake_employee_service.received_messages.should == [:update_employee]
        end

        it 'redirects to the employee' do
          controller.load_employee_service(Faker.new(true))
          employee = create(:employee, customer: customer)

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          response.should redirect_to(employee)
          flash[:notice].should == 'Employee was successfully updated.'
        end
      end

      describe 'with invalid params' do
        it 'assigns the employee as @employee' do
          employee = create(:employee, customer: customer)
          controller.load_employee_service(Faker.new(false))

          put :update, {:id => employee.to_param, :employee => {'name' => 'invalid value'}}, {}

          assigns(:employee).should eq(employee)
        end

        it "re-renders the 'edit' template" do
          employee = create(:employee, customer: customer)
          controller.load_employee_service(Faker.new(false))

          put :update, {:id => employee.to_param, :employee => {'name' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns sorted locations' do
          employee = create(:employee, customer: customer)
          location = build(:location)
          fake_location_list_presenter = Faker.new([location])
          LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
          controller.load_employee_service(Faker.new(false))

          put :update, {:id => employee.to_param, :employee => {'name' => 'invalid value'}}, {}

          assigns(:locations).should == [location]
          fake_location_list_presenter.received_message.should == :sort
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'updates the requested employee' do
        employee = create(:employee, customer: customer)
        fake_employee_service = controller.load_employee_service(Faker.new(true))

        put :update, {:id => employee.to_param, :employee =>
          {
            'first_name' => 'Susie',
            'last_name' => 'Sampson',
            'employee_number' => 'newEmpNum',
            'location_id' => 1
          }
        }, {}

        fake_employee_service.received_messages.should == [:update_employee]
      end

      it 'assigns the requested employee as @employee' do
        employee = create(:employee, customer: customer)
        controller.load_employee_service(Faker.new(true))

        put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

        assigns(:employee).should eq(employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create(:employee, customer: customer)

        put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

        assigns(:employee).should be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      context 'when destroy call succeeds' do
        it 'calls EmployeesService' do
          employee = create(:employee, customer: customer)
          fake_employee_service = controller.load_employee_service(Faker.new(true))

          delete :destroy, {:id => employee.to_param}, {}

          fake_employee_service.received_message.should == :delete_employee
        end

        it 'redirects to the employee list' do
          employee = create(:employee, customer: customer)
          controller.load_employee_service(Faker.new(true))

          delete :destroy, {:id => employee.to_param}, {}

          response.should redirect_to(employees_url)
          flash[:notice].should == 'Employee was successfully deleted.'
        end
      end

      context 'when destroy call fails' do
        context 'when destroy call fails' do
          before do
            employee = create(:employee, customer: customer)

            employee_service = double('employee_service')
            employee_service.stub(:delete_employee).and_return(false)

            certification_service = double('certification_service')
            certification_service.stub(:get_all_certifications_for_employee).and_return([])

            controller.load_employee_service(employee_service)
            controller.load_certification_service(certification_service)

            delete :destroy, {id: employee.to_param}, {}
          end

          it 'should render show page' do
            response.should render_template('show')
          end

          it 'should assign @certifications' do
            expect(assigns(:certifications)).to eq([])
          end
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls EmployeesService' do
        employee = create(:employee, customer: customer)
        controller.load_employee_service(Faker.new(true))

        delete :destroy, {:id => employee.to_param}, {}
      end
    end
  end

  def employee_attributes
    {
      first_name: 'John',
      last_name: 'Smith',
      employee_number: '876ABC'
    }
  end
end

def a_presentable_employee_for(employee)
  EmployeePresenter.new(employee)
end

