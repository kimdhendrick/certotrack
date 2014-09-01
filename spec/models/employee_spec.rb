require 'spec_helper'

describe Employee do
  let(:employee) { build(:employee) }

  subject { employee }

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :employee_number }
  it { should validate_presence_of :customer }
  it { should validate_presence_of :created_by }
  it { should validate_presence_of :location }
  it { should validate_uniqueness_of(:employee_number).scoped_to(:customer_id) }
  it { should belong_to(:customer) }
  it { should belong_to(:location) }
  it { should have_many(:certifications) }
  it { should have_many(:equipments) }
  it_should_behave_like 'a stripped model', 'first_name'
  it_should_behave_like 'a stripped model', 'last_name'
  it_should_behave_like 'a stripped model', 'employee_number'

  describe 'uniqueness of employee_number' do
    let(:customer) { create(:customer) }

    before do
      create(:employee, employee_number: 'cat', customer: customer)
    end

    subject { Employee.new(customer: customer) }

    it_should_behave_like 'a model that prevents duplicates', 'cat', 'employee_number'
  end

  it 'should default active to true' do
    employee = Employee.new
    employee.active.should be_true
  end

  describe '#destroy' do
    before { employee.save }

    context 'when employee has no certifications and no equipment' do
      it 'should destroy employee' do
        expect { employee.destroy }.to change(Employee, :count).by(-1)
      end
    end

    context 'when employee has one or more certifications' do
      before { create(:certification, employee: employee) }

      it 'should not destroy employee' do
        expect { employee.destroy }.to_not change(Employee, :count)
      end

      it 'should have a base error' do
        employee.destroy

        employee.errors[:base].first.should == 'Employee has certifications, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      end
    end

    context 'when employee has one or more pieces of equipment' do
      before { create(:equipment, employee: employee) }

      it 'should not destroy employee' do
        expect { employee.destroy }.to_not change(Employee, :count)
      end

      it 'should have a base error' do
        employee.destroy

        employee.errors[:base].first.should == 'Employee has equipment assigned, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      end
    end

    context 'when employee has one or more pieces of equipment and certifications' do
      before do
        create(:equipment, employee: employee)
        create(:certification, employee: employee)
      end

      it 'should not destroy employee' do
        expect { employee.destroy }.to_not change(Employee, :count)
      end

      it 'should have base errors' do
        employee.destroy

        employee.errors[:base].should include 'Employee has equipment assigned, you must remove them before deleting the employee. Or Deactivate the employee instead.'
        employee.errors[:base].should include 'Employee has certifications, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      end
    end
  end
end