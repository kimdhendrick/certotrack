require 'spec_helper'

describe BatchCertificationsController do
  let(:customer) { create(:customer) }
  let(:employee) { create(:employee, customer: customer) }
  let(:certification_type) { create(:certification_type, customer: customer) }
  let(:certification) { create(:certification, certification_type: certification_type, customer: customer) }

  describe 'POST create' do
    before do
      sign_in stub_certification_user(customer)
    end

    it 'should set success message on success' do
      params = {
        employee_id: employee.id,
        certification_ids: []
      }

      post :create, params, {}

      flash[:success].should == 'Certifications updated successfully.'
    end

    it 'should redirect to employee on success' do
      params = {
        employee_id: employee.id,
        certification_ids: []
      }

      post :create, params, {}

      response.should redirect_to(employee)
    end

    it 'should redirect to certification type on success' do
      params = {
        certification_type_id: certification_type.id,
        certification_ids: []
      }

      post :create, params, {}

      response.should redirect_to(certification_type)
    end

    it 'should render certification_type show on error' do
      fake_batch_certification = BatchCertification.new({certification_type_id: certification_type.id,
                                                         certification_ids: [certification.id]})
      fake_batch_certification.stub(:update).and_return(false)
      controller.load_batch_certification(fake_batch_certification)

      params = {
        certification_type_id: certification_type.id,
        certification_ids: []
      }

      post :create, params, {}

      response.should render_template('certification_types/show')
    end

    it 'should render employee show on error' do
      fake_batch_certification = BatchCertification.new({employee_id: employee.id,
                                                        certification_ids: [certification.id]})
      fake_batch_certification.stub(:update).and_return(false)
      controller.load_batch_certification(fake_batch_certification)


      params = {
        employee_id: employee.id,
        certification_ids: []
      }

      post :create, params, {}

      response.should render_template('employees/show')
    end

    it 'should sets values for employee/show view on error' do
      fake_batch_certification = BatchCertification.new({employee_id: employee.id, certification_ids: []})
      fake_batch_certification.stub(:update).and_return(false)
      fake_batch_certification.stub(:employee).and_return(employee)
      fake_batch_certification.stub(:certifications).and_return([CertificationPresenter.new(certification)])
      controller.load_batch_certification(fake_batch_certification)

      params = {
        employee_id: employee.id,
        certification_ids: []
      }

      post :create, params, {}

      assigns(:employee).should == employee
      assigns(:certifications).map(&:model).should == [certification]
      assigns(:batch_certification).should == fake_batch_certification
    end

    it 'should authorize each certification' do
      certification_for_other_customer = CertificationPresenter.new(create(:certification))
      fake_batch_certification = BatchCertification.new({employee_id: employee.id, certification_ids: []})
      fake_batch_certification.stub(:update).and_return(false)
      fake_batch_certification.stub(:employee).and_return(employee)
      fake_batch_certification.stub(:certifications).and_return([certification_for_other_customer])
      controller.load_batch_certification(fake_batch_certification)

      params = {
        employee_id: employee.id,
        certification_ids: []
      }

      post :create, params, {}

      response.should redirect_to root_url
      assigns(:employee).should be_nil
      assigns(:certifications).should be_nil
    end
  end
end
