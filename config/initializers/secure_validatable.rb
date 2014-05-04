module Devise
  module Models
    module SecureValidatable
      def self.included(base)
        base.extend ClassMethods
        assert_secure_validations_api!(base)

        base.class_eval do
          unless has_uniqueness_validation_of_login?
            validates login_attribute, :uniqueness => {
              :scope => authentication_keys[1..-1],
              :case_sensitive => !!case_insensitive_keys
            }, :if => "#{login_attribute}_changed?".to_sym
          end

          validates :password, :presence => true, :length => password_length, :confirmation => true, :if => :password_required?
          validates :password, :format => {:with => password_regex, :message => :password_format}, :if => :password_required?
          validate :current_equal_password_validation
        end
      end
    end
  end
end