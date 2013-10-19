require 'spec_helper'

describe BatchCertification do
  let (:employee) { create(:employee) }
  let! (:certification_type) { create(:units_based_certification_type) }
  let! (:certification) { create(:certification, certification_type: certification_type, employee: employee) }

  describe '#initialize' do
    it 'should set employee if provided' do
      batch_certification = BatchCertification.new({employee_id: employee.id, certification_ids: {}})

      batch_certification.employee.should == employee
    end

    it 'should set certification type if provided' do
      batch_certification = BatchCertification.new({certification_type_id: certification_type.id, certification_ids: {}})

      batch_certification.certification_type.should == certification_type
    end

    it 'should set certifications' do
      batch_certification = BatchCertification.new({employee_id: employee.id, certification_ids: {}})

      batch_certification.certifications.map(&:model).should == [certification]
    end

    it 'should set certifications_attributes' do
      batch_certification = BatchCertification.new(
        {
          employee_id: employee.id,
          certification_ids: {"#{certification.id}" => '32'},
        })

      batch_certification.certification_attributes.should ==
        [
          {
            certification_id: 1,
            units_achieved: '32'
          }
        ]
    end
  end

  describe '#update' do
    it 'should update certification' do
      certification.update_attribute(:units_achieved, 0)

      batch_certification = BatchCertification.new(
        {
          employee_id: employee.id,
          certification_ids: {"#{certification.id}" => '32'},
        })

      batch_certification.update.should be_true

      certification.reload
      certification.units_achieved.should == 32
    end

    it 'should not update certification when errors' do
      certification.update_attribute(:units_achieved, 0)
      Certification.any_instance.stub(:update_attributes!).and_raise(ActiveRecord::RecordInvalid.new(certification))

      batch_certification = BatchCertification.new(
        {
          employee_id: employee.id,
          certification_ids: {"#{certification.id}" => '32'},
        })

      batch_certification.update.should be_false

      certification.reload
      certification.units_achieved.should == 0
    end
  end

  describe '#error' do
    it 'should return nil if no errors' do
      batch_certification = BatchCertification.new({employee_id: employee.id, certification_ids: {}})
      batch_certification.error(certification.id).should be_nil
    end

    it 'should return certification errors' do
      certification.update_attribute(:units_achieved, 0)
      batch_certification = BatchCertification.new(
        {
          employee_id: employee.id,
          certification_ids: {"#{certification.id}" => '-99'},
        })

      batch_certification.update

      batch_certification.error(certification.id).should == 'Active certification period units achieved must be greater than or equal to 0'
    end
  end

  describe '#units' do
    it 'should return units sent on update' do
      certification.update_attribute(:units_achieved, 0)
      batch_certification = BatchCertification.new(
        {
          employee_id: employee.id,
          certification_ids: {"#{certification.id}" => '-999'},
        })

      batch_certification.update

      batch_certification.units(certification.id).should == '-999'
    end
  end
end