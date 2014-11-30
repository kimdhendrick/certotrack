require 'spec_helper'

module Api
  describe EquipmentController do
    let(:customer) { build(:customer) }
    let(:equipment) { build(:equipment, name: 'Meter', serial_number: 'Meter123') }
    let(:fake_equipment_service_that_returns_list) { Faker.new([equipment]) }

    describe 'GET #index' do
      context 'when equipment user' do
        let(:my_user) { stub_equipment_user(customer) }

        before do
          sign_in my_user
        end

        context 'JSON format' do
          it 'calls get_all_equipment with current_user and params' do
            fake_equipment_service = controller.load_equipment_service(Faker.new([]))
            fake_equipment_list_presenter = Faker.new([])
            EquipmentListPresenter.stub(:new).and_return(fake_equipment_list_presenter)
            params = {'sort' => 'name', 'direction' => 'asc'}

            get :index, params

            fake_equipment_service.received_messages.should == [:get_all_equipment]
            fake_equipment_service.received_params[0].should == my_user

            fake_equipment_list_presenter.received_message.should == :sort
            fake_equipment_list_presenter.received_params[0]['sort'].should == 'name'
            fake_equipment_list_presenter.received_params[0]['direction'].should == 'asc'
          end

          it 'assigns equipment as @equipment' do
            controller.load_equipment_service(fake_equipment_service_that_returns_list)

            get :index

            JSON.parse(response.body).should ==
              [
                {
                  'id' => nil,
                  'serial_number' => 'Meter123',
                  'last_inspection_date' => '2000-01-01',
                  'inspection_interval' => 'Annually',
                  'name' => 'Meter',
                  'expiration_date' => nil,
                  'comments' => nil,
                  'created_at' => nil,
                  'updated_at' => nil,
                  'customer_id' => 2,
                  'location_id' => nil,
                  'employee_id' => nil,
                  'created_by' => 'username'
                }
              ]
          end
        end
      end
    end

    describe 'GET #names' do
      context 'when equipment user' do
        let(:my_user) { stub_equipment_user(customer) }

        before do
          sign_in my_user
        end

        context 'JSON format' do
          it 'calls get_all_equipment with current_user and params' do
            fake_equipment_service = controller.load_equipment_service(Faker.new([]))

            get :names, {}

            fake_equipment_service.received_messages.should == [:get_equipment_names]
            fake_equipment_service.received_params[0].should == my_user
            fake_equipment_service.received_params[1].should == ''
          end

          it 'returns equipment information' do
            controller.load_equipment_service(Faker.new(['Box', 'Meter']))

            get :names, {}

            JSON.parse(response.body).should == ['Box', 'Meter']
          end
        end
      end
    end

    describe 'GET #find_all_by_name' do
      context 'when equipment user' do
        let(:my_user) { stub_equipment_user(customer) }

        before do
          sign_in my_user
        end

        context 'JSON format' do
          it 'calls get_all_equipment with current_user and params' do
            fake_equipment_service = controller.load_equipment_service(Faker.new([]))

            get :find_all_by_name, {name: 'box'}

            fake_equipment_service.received_messages.should == [:search_equipment]
            fake_equipment_service.received_params[0].should == my_user
            fake_equipment_service.received_params[1].should == {name: 'box'}
          end

          it 'returns equipment information' do
            controller.load_equipment_service(Faker.new([equipment]))

            get :find_all_by_name, {name: 'box'}

            JSON.parse(response.body).should == [
              {
                'id' => nil,
                'serial_number' => 'Meter123',
                'last_inspection_date' => '2000-01-01',
                'inspection_interval' => 'Annually',
                'name' => 'Meter',
                'expiration_date' => nil,
                'comments' => nil,
                'created_at' => nil,
                'updated_at' => nil,
                'customer_id' => 2,
                'location_id' => nil,
                'employee_id' => nil,
                'created_by' => 'username'
              }
            ]
          end
        end
      end
    end
  end
end

