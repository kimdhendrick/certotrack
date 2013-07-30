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

    # TODO
    if user.role?('certification')
      can :manage, :certification
    end

    # TODO
    if user.role?('vehicle')
      can :manage, :vehicle
    end
  end
end
