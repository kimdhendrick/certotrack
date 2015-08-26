require 'spec_helper'

describe EmployeeReactivationService do
  describe '#reactivate_employee' do
    it 'makes employee active' do
      employee = build(:employee, active: false)

      described_class.new.reactivate_employee(employee)

      employee.should be_active
    end

    it "clears the employee's deactivation date" do
      employee = create(:employee, active: false, deactivation_date: Date.yesterday)

      described_class.new.reactivate_employee(employee)

      employee.reload
      employee.deactivation_date.should be_nil
    end

    it "reactivates employee's certifications" do
      employee = create(:employee)
      certification = create(:certification, employee: employee, customer: employee.customer, active: false)

      described_class.new.reactivate_employee(employee)

      certification.reload
      certification.should be_active
    end

    it "does not reactivate other employees' certifications" do
      employee = create(:employee)
      other_employee = create(:employee)
      certification = create(:certification, employee: employee, customer: employee.customer, active: false)
      other_certification = create(:certification, employee: other_employee, customer: other_employee.customer, active: false)

      described_class.new.reactivate_employee(employee)

      certification.reload
      certification.should be_active

      other_certification.reload
      other_certification.should_not be_active
    end

    it "reactivates deactivated employees and certifications" do
      employee = create(:employee)
      certification = create(:certification, employee: employee, customer: employee.customer)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      employee.reload
      employee.should_not be_active

      certification.reload
      certification.should_not be_active

      described_class.new.reactivate_employee(employee)

      employee.reload
      employee.should be_active

      certification.reload
      certification.should be_active
    end
  end
end
