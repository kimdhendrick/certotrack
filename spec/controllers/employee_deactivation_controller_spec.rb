require 'spec_helper'

describe EmployeeDeactivationController do
  let(:customer) {create(:customer)}

  describe 'GET deactivate' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'calls EmployeesService' do
        employee = create(:employee, customer: customer)
        fake_employee_service = controller.load_employee_deactivation_service(Faker.new(true))

        delete :deactivate, {:id => employee.to_param}, {}

        fake_employee_service.received_message.should == :deactivate_employee
        fake_employee_service.received_params[0].should == employee
      end

      it 'redirects to the employee list' do
        employee = create(:employee, customer: customer, last_name: 'last', first_name: 'first')
        controller.load_employee_deactivation_service(Faker.new(true))

        delete :deactivate, {:id => employee.to_param}, {}

        response.should redirect_to(employees_url)
        flash[:notice].should == 'Employee last, first deactivated'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls EmployeesService' do
        employee = create(:employee, customer: customer)
        controller.load_employee_deactivation_service(Faker.new(true))

        delete :deactivate, {:id => employee.to_param}, {}
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not deactivate' do
        employee = build(:employee)
        fake_employee_service = controller.load_employee_deactivation_service(Faker.new([employee]))

        get :deactivated_employees

        fake_employee_service.received_message.should be_nil
      end
    end
  end

  describe 'GET deactivate_confirm' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'calls service and makes assignments' do
        employee = create(:employee, customer: customer)
        certification = create(:certification, employee: employee, customer: customer)
        equipment = build(:equipment)
        fake_equipment_service = controller.load_equipment_service(Faker.new([equipment]))
        fake_certification_service = controller.load_certification_service(Faker.new([certification]))

        get :deactivate_confirm, {:id => employee.to_param}, {}

        assigns(:employee).should eq(employee)
        assigns(:equipments).map(&:model).should eq([equipment])
        assigns(:certifications).map(&:model).should eq([certification])
        fake_equipment_service.received_message.should == :get_all_equipment_for_employee
        fake_equipment_service.received_params[0].should == employee
        fake_certification_service.received_message.should == :get_all_certifications_for_employee
        fake_certification_service.received_params[0].should == employee
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls service and makes assignments' do
        employee = create(:employee, customer: customer)
        equipment = build(:equipment)
        fake_equipment_service = controller.load_equipment_service(Faker.new([equipment]))

        get :deactivate_confirm, {:id => employee.to_param}, {}

        assigns(:employee).should eq(employee)
        assigns(:equipments).map(&:model).should eq([equipment])
        fake_equipment_service.received_message.should == :get_all_equipment_for_employee
        fake_equipment_service.received_params[0].should == employee
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign anything' do
        employee = create(:employee, customer: customer)

        get :deactivate_confirm, {:id => employee.to_param}, {}

        assigns(:employee).should be_nil
        assigns(:equipments).should be_nil
      end
    end
  end

  describe 'GET deactivated_employees' do
    it 'calls get_deactivated_employees with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_employee_service = controller.load_employee_deactivation_service(Faker.new([]))
      params = {}

      get :deactivated_employees, params

      fake_employee_service.received_messages.should == [:get_deactivated_employees]
      fake_employee_service.received_params[0].should == my_user
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns @employees and @employee_count' do
        employee = build(:employee)
        controller.load_employee_deactivation_service(Faker.new([employee]))

        get :deactivated_employees

        assigns(:employees).map(&:model).should eq([employee])
        assigns(:employee_count).should eq(1)
      end

      context 'CSV export' do
        it 'responds to csv format' do
          controller.load_employee_deactivation_service(Faker.new([build(:employee)]))

          get :deactivated_employees, format: 'csv'

          response.headers['Content-Type'].should == 'text/csv; charset=utf-8'
          response.body.split("\n").count.should == 2
        end

        it 'calls CsvPresenter#present with certifications' do
          my_user = stub_certification_user(customer)
          sign_in my_user
          employee = build(:employee)
          fake_deactivation_service = controller.load_employee_deactivation_service(Faker.new([employee]))
          fake_csv_presenter = Faker.new
          CsvPresenter.should_receive(:new).with([employee]).and_return(fake_csv_presenter)

          get :deactivated_employees, format: 'csv'

          fake_deactivation_service.received_messages.should == [:get_deactivated_employees]
          fake_deactivation_service.received_params[0].should == my_user

          fake_csv_presenter.received_message.should == :present
        end
      end

      context 'PDF export' do
        it 'responds to pdf format' do
          controller.load_employee_deactivation_service(Faker.new([build(:employee)]))

          get :deactivated_employees, format: 'pdf'

          response.headers['Content-Type'].should == 'application/pdf'
        end

        it 'calls PdfPresenter#present with certifications' do
          my_user = stub_certification_user(customer)
          sign_in my_user
          employee = build(:employee)
          fake_deactivation_service = controller.load_employee_deactivation_service(Faker.new([employee]))
          fake_pdf_presenter = Faker.new
          PdfPresenter.should_receive(:new).with([employee], 'Deactivated Employee List', {}).and_return(fake_pdf_presenter)

          get :deactivated_employees, format: 'pdf'

          fake_deactivation_service.received_messages.should == [:get_deactivated_employees]
          fake_deactivation_service.received_params[0].should == my_user

          fake_pdf_presenter.received_message.should == :present
        end
      end

      context 'Excel export' do
        it 'responds to excel format' do
          controller.load_employee_deactivation_service(Faker.new([build(:employee)]))

          get :deactivated_employees, format: 'xls'

          response.headers['Content-Type'].should == 'application/vnd.ms-excel'
        end

        it 'calls ExcelPresenter#present with certifications' do
          my_user = stub_certification_user(customer)
          sign_in my_user
          employee = build(:employee)
          fake_deactivation_service = controller.load_employee_deactivation_service(Faker.new([employee]))
          fake_xls_presenter = Faker.new
          ExcelPresenter.should_receive(:new).with([employee], 'Deactivated Employee List').and_return(fake_xls_presenter)

          get :deactivated_employees, format: 'xls'

          fake_deactivation_service.received_messages.should == [:get_deactivated_employees]
          fake_deactivation_service.received_params[0].should == my_user

          fake_xls_presenter.received_message.should == :present
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns employees as @employees' do
        employee = build(:employee)
        controller.load_employee_deactivation_service(Faker.new([employee]))

        get :deactivated_employees

        assigns(:employees).map(&:model).should eq([employee])
        assigns(:employee_count).should eq(1)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employees as @employees' do
        employee = build(:employee)
        controller.load_employee_deactivation_service(Faker.new([employee]))

        get :deactivated_employees

        assigns(:employees).should be_nil
        assigns(:employee_count).should be_nil
      end
    end
  end
end