require 'spec_helper'

module Api
  describe EquipmentController do
    let(:customer) { build(:customer) }
    let(:equipment) do
      create(
        :equipment,
        id: 99,
        name: 'Meter',
        serial_number: 'Meter123',
        expiration_date: Date.new(2001, 1, 1),
        last_inspection_date: Date.new(2000, 1, 1),
        inspection_interval: Interval::ONE_YEAR.text,
        comments: 'This is a comment',
        employee: create(:employee, first_name: 'Joe', last_name: 'Schmoe')
      )
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

          context 'when assigned to an employee' do
            it 'returns equipment information' do
              controller.load_equipment_service(Faker.new([equipment]))

              get :find_all_by_name, {name: 'box'}

              JSON.parse(response.body).should == [
                {
                  'id' => 99,
                  'name' => 'Meter',
                  'serial_number' => 'Meter123',
                  'status' => 'Expired',
                  'expiration_date' => '01/01/2001',
                  'last_inspection_date' => '01/01/2000',
                  'inspection_interval' => 'Annually',
                  'assigned_to' => 'Schmoe, Joe',
                  'comments' => 'This is a comment'
                }
              ]
            end
          end

          context 'when assigned to a location' do
            it 'returns equipment information' do
              equipment = create(
                :equipment,
                id: 99,
                name: 'Meter',
                serial_number: 'Meter123',
                expiration_date: Date.new(2001, 1, 1),
                last_inspection_date: Date.new(2000, 1, 1),
                inspection_interval: Interval::ONE_YEAR.text,
                comments: 'This is a comment',
                location: create(:location, name: 'Golden')
              )

              controller.load_equipment_service(Faker.new([equipment]))

              get :find_all_by_name, {name: 'box'}

              JSON.parse(response.body).should == [
                {
                  'id' => 99,
                  'name' => 'Meter',
                  'serial_number' => 'Meter123',
                  'status' => 'Expired',
                  'expiration_date' => '01/01/2001',
                  'last_inspection_date' => '01/01/2000',
                  'inspection_interval' => 'Annually',
                  'assigned_to' => 'Golden',
                  'comments' => 'This is a comment'
                }
              ]
            end
          end

          context 'when unassigned' do
            it 'returns equipment information' do
              equipment = create(
                :equipment,
                id: 99,
                name: 'Meter',
                serial_number: 'Meter123',
                expiration_date: Date.new(2001, 1, 1),
                last_inspection_date: Date.new(2000, 1, 1),
                inspection_interval: Interval::ONE_YEAR.text,
                comments: 'This is a comment',
                location: nil,
                employee: nil
              )

              controller.load_equipment_service(Faker.new([equipment]))

              get :find_all_by_name, {name: 'box'}

              JSON.parse(response.body).should == [
                {
                  'id' => 99,
                  'name' => 'Meter',
                  'serial_number' => 'Meter123',
                  'status' => 'Expired',
                  'expiration_date' => '01/01/2001',
                  'last_inspection_date' => '01/01/2000',
                  'inspection_interval' => 'Annually',
                  'assigned_to' => 'Unassigned',
                  'comments' => 'This is a comment'
                }
              ]
            end
          end
        end
      end
    end
  end
end

