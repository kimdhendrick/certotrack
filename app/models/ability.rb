class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role?('admin')
      can :manage, :all
    end

    if user.role?('equipment')
      can :create, :equipment
      can :read, :equipment

      can :manage, Equipment do |equipment|
        equipment.try(:customer) == user.customer
      end
    end

    if user.role?('certification')
      can :create, :certification
      can :read, :certification

      can :manage, CertificationType do |certification_type|
        certification_type.try(:customer) == user.customer
      end

      can :manage, Certification do |certification|
        certification.try(:customer) == user.customer
      end

      can :manage, Employee do |employee|
        employee.try(:customer) == user.customer
      end
    end
  end
end
