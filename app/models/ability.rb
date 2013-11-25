class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role?('admin')
      can :manage, :all
    end

    if _equipment_user?(user) || _certification_user?(user)
      can :read, :employee
      can :manage, Employee do |employee|
        employee.try(:customer) == user.customer
      end

      can :read, :location
      can :manage, Location do |location|
        location.try(:customer) == user.customer
      end
    end

    if _equipment_user?(user)
      can :create, :equipment
      can :read, :equipment

      can :manage, Equipment do |equipment|
        equipment.try(:customer) == user.customer
      end
    end

    if _certification_user?(user)
      can :create, :certification
      can :read, :certification

      can :manage, CertificationType do |certification_type|
        certification_type.try(:customer) == user.customer
      end

      can :manage, Certification do |certification|
        certification.try(:customer) == user.customer
      end
    end
  end

  private

  def _certification_user?(user)
    user.role?('certification')
  end

  def _equipment_user?(user)
    user.role?('equipment')
  end
end
