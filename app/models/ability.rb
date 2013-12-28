class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new

    can :manage, :all if _admin_user?

    _setup_abilities_for([Equipment]) if _equipment_user?
    _setup_abilities_for([Certification, CertificationType]) if _certification_user?
    _setup_abilities_for([Vehicle, ServiceType, Service]) if _vehicle_user?
    _setup_abilities_for([Location]) if _location_user?
    _setup_abilities_for([Employee]) if _employee_user?
  end

  private

  attr_reader :user

  def _admin_user?
    user.role?('admin')
  end

  def _certification_user?
    user.role?('certification')
  end

  def _equipment_user?
    user.role?('equipment')
  end

  def _vehicle_user?
    user.role?('vehicle')
  end

  def _employee_user?
    _equipment_user? || _certification_user?
  end

  def _location_user?
    _equipment_user? || _certification_user? || _vehicle_user?
  end

  def _setup_abilities_for(resource_classes)
    resource_classes.each do |resource_class|
      resource = resource_class.name.underscore.to_sym
      can :read, resource
      can :create, resource

      can :manage, resource_class do |resource_instance|
        resource_instance.try(:customer) == user.customer
      end
    end
  end
end
