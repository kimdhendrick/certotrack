module UserRoleHelper
  ROLES = [
    ROLE_VEHICLE = 'vehicle',
    ROLE_EQUIPMENT = 'equipment',
    ROLE_CERTIFICATION = 'certification'
  ]

  def self.role?(user, role)
    user.roles.include?(role)
  end

  def self.set_roles(user, roles)
    user.roles_mask = (roles & ROLES).map { |role| _role_mask(role) }.sum
  end

  def self.roles(user)
    ROLES.reject { |role| ((user.roles_mask || 0) & _role_mask(role)).zero? }
  end

  def self.add_role(user, role)
    return if role?(user, role)

    user.roles_mask = (user.roles_mask || 0) + _role_mask(role)
  end

  def self.remove_role(user, role)
    return if !role?(user, role)

    user.roles_mask -= _role_mask(role)
  end

  def self.role_where_clause(role)
    "roles_mask & #{(2**ROLES.index(role.to_s))} > 0"
  end

  private

  def self._role_mask(role)
    2**ROLES.index(role)
  end
end