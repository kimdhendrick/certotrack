require 'spec_helper'

describe TrainingEventsController do

  let(:customer) { create(:customer) }
  let (:current_user) { stub_certification_user(customer) }
  let (:my_employee) { create(:employee, customer: customer) }
  let (:my_certification_type) { create(:certification_type, customer: customer) }

  context '#GET list_employees' do

    before do
      sign_in current_user
    end

    it 'assigns employees to @employees' do
      fake_employee_service = Faker.new([my_employee])
      controller.load_employee_service(fake_employee_service)

      get :list_employees, {}, {}

      assigns(:employees).map(&:model).should == [my_employee]
      fake_employee_service.received_message.should == :get_all_employees
      fake_employee_service.received_params[0].should == current_user
    end
  end

  context '#GET list_certification_types' do

    before do
      sign_in current_user
    end

    it 'assigns certification_types to @certification_types' do
      fake_certification_type_service = Faker.new([my_certification_type])
      controller.load_certification_type_service(fake_certification_type_service)

      get :list_certification_types, {employee_ids: []}, {}

      assigns(:certification_types).map(&:model).should == [my_certification_type]
      fake_certification_type_service.received_message.should == :get_all_certification_types
      fake_certification_type_service.received_params[0].should == current_user
    end

    it 'assigns employee_ids to @employee_ids' do
      controller.load_certification_type_service(Faker.new)

      get :list_certification_types, {:employee_ids => [1, 2, 3]}, {}

      assigns(:employee_ids).should == '1,2,3'
    end

    it 'redirects if no employees selected' do
      get :list_certification_types, {employee_ids: nil}, {}

      response.should redirect_to employee_list_training_event_path
      flash[:success].should == 'Please select at least one Employee.'
    end
  end

  context '#GET new' do
    before do
      sign_in current_user
    end

    it 'assigns @employees' do
      fake_employee_service = Faker.new([my_employee])
      controller.load_employee_service(fake_employee_service)
      controller.load_certification_type_service(Faker.new([]))

      params = {
        :employee_ids => "#{my_employee.id}",
        :certification_type_ids => []
      }

      get :new, params, {}

      assigns(:employees).should == [my_employee]

      fake_employee_service.received_message.should == :find
      fake_employee_service.received_params[0].should == [my_employee.id]
      fake_employee_service.received_params[1].should == current_user
    end

    it 'assigns @certification_types' do
      controller.load_employee_service(Faker.new([]))
      fake_certification_type_service = Faker.new([my_certification_type])
      controller.load_certification_type_service(fake_certification_type_service)

      params = {
        :employee_ids => "1",
        :certification_type_ids => ["#{my_certification_type.id}"]
      }

      get :new, params, {}

      assigns(:certification_types).should == [my_certification_type]

      fake_certification_type_service.received_message.should == :find
      fake_certification_type_service.received_params[0].should == current_user
      fake_certification_type_service.received_params[1].should == [my_certification_type.id]
    end

    it 'redirects if no certification types selected' do
      get :new, {certification_type_ids: nil, employee_ids: '1'}, {}

      response.should render_template('training_events/list_certification_types')
      flash[:success].should == 'Please select at least one Certification Type.'
    end
  end

  context '#POST create' do
    context 'when certification user' do
      before do
        sign_in current_user
      end

      it 'assigns @employees' do
        my_employee = create(:employee, customer: customer)
        fake_employee_service = Faker.new([my_employee])
        controller.load_employee_service(fake_employee_service)

        get :create, {employee_ids: ["#{my_employee.id}"], certification_type_ids: []}, {}

        assigns(:employees).should == [my_employee]
        fake_employee_service.received_message.should == :find
        fake_employee_service.received_params[0].should == [my_employee.id]
        fake_employee_service.received_params[1].should == current_user
      end

      it 'does not assign unauthorized employees' do
        my_employee = create(:employee, customer: create(:customer))
        controller.load_employee_service(Faker.new([my_employee]))

        get :create, {employee_ids: ["#{my_employee.id}"], certification_type_ids: []}, {}

        assigns(:employees).should be_nil
      end

      it 'assigns @certification_types' do
        my_certification_type = create(:certification_type, customer: customer)
        fake_certification_type_service = Faker.new([my_certification_type])
        controller.load_certification_type_service(fake_certification_type_service)

        get :create, {employee_ids: [], certification_type_ids: ["#{my_certification_type.id}"]}, {}

        assigns(:certification_types).should == [my_certification_type]
        fake_certification_type_service.received_message.should == :find
        fake_certification_type_service.received_params[0].should == current_user
        fake_certification_type_service.received_params[1].should == [my_certification_type.id]
      end

      it 'does not assign unauthorized certification_types' do
        my_certification_type = create(:certification_type, customer: create(:customer))
        controller.load_certification_type_service(Faker.new([my_certification_type]))

        get :create, {employee_ids: [], certification_type_ids: ["#{my_certification_type.id}"]}, {}

        assigns(:certification_types).should be_nil
      end

      it 'assigns @trainer' do
        get :create, {trainer: 'Joe', employee_ids: [], certification_type_ids: []}, {}

        assigns(:trainer).should == 'Joe'
      end

      it 'assigns @certification_date' do
        get :create, {certification_date: '11/10/2013', employee_ids: [], certification_type_ids: []}, {}

        assigns(:certification_date).should == '11/10/2013'
      end

      it 'creates training event and renders confirmation' do
        fake_training_event_service = Faker.new(
          {
            success: true,
            employees_with_errors: [],
            certification_types_with_errors: []
          }
        )
        controller.load_training_event_service(fake_training_event_service)

        my_employee = create(:employee, customer: customer)
        my_certification_type = create(:certification_type, customer: customer)

        get :create, {
          employee_ids: ["#{my_employee.id}"],
          certification_type_ids: ["#{my_certification_type.id}"],
          certification_date: '11/10/2013',
          trainer: 'trainer'
        }, {}

        fake_training_event_service.received_message.should == :create_training_event
        fake_training_event_service.received_params[0].should == current_user
        fake_training_event_service.received_params[1].should == [my_employee.id]
        fake_training_event_service.received_params[2].should == [my_certification_type.id]
        fake_training_event_service.received_params[3].should == '11/10/2013'
        fake_training_event_service.received_params[4].should == 'trainer'

        response.should render_template('training_events/create')
        assigns(:employees_with_errors).should == []
        assigns(:certification_types_with_errors).should == []
      end

      it 'renders errors when training event has errors' do
        my_employee = create(:employee, customer: customer)
        my_certification_type = create(:certification_type, customer: customer)
        fake_training_event_service = Faker.new(
          {
            success: false,
            employees_with_errors: [my_employee],
            certification_types_with_errors: [my_certification_type]
          }
        )
        controller.load_training_event_service(fake_training_event_service)

        get :create, {
          employee_ids: ["#{my_employee.id}"],
          certification_type_ids: ["#{my_certification_type.id}"]
        }, {}

        response.should render_template('training_events/create')
        assigns(:employees_with_errors).should == [my_employee]
        assigns(:certification_types_with_errors).should == [my_certification_type]
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns all employees' do
        my_employee = create(:employee, customer: create(:customer))
        controller.load_employee_service(Faker.new([my_employee]))

        get :create, {employee_ids: ["#{my_employee.id}"], certification_type_ids: []}, {}

        assigns(:employees).should == [my_employee]
      end

      it 'assigns all certification_types' do
        my_certification_type = create(:certification_type, customer: create(:customer))
        controller.load_certification_type_service(Faker.new([my_certification_type]))

        get :create, {employee_ids: [], certification_type_ids: ["#{my_certification_type.id}"]}, {}

        assigns(:certification_types).should == [my_certification_type]
      end

    end
  end
end
