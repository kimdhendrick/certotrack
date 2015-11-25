class RegistrationService
  def initialize(customer_service: CustomerService.new,
                 user_service: UserService.new,
                 payment_service: PaymentService.new)
    @customer_service = customer_service
    @user_service = user_service
    @payment_service = payment_service
  end

  def register(params)
    success = false
    registration = nil

    ActiveRecord::Base.transaction do
      registration, success = _create_registration(params)
      customer, success = _create_customer(params, registration, success)
      success = _create_user(customer, params, registration, success)
      success = success && _process_payment(customer, params)
      raise ActiveRecord::Rollback unless success
    end

    return success, registration
  end

  private

  attr_reader :customer_service, :user_service, :payment_service

  def _create_registration(params)
    registration = Registration.new(_registration_params(params))
    return registration, registration.valid?
  end

  def _create_customer(params, registration, success)
    return nil, false unless success

    customer = customer_service.create_customer(_customer_params(params))
    customer.errors.each { |attribute, error| registration.add_errors(attribute, error) }
    return customer, customer.persisted?
  end

  def _create_user(customer, params, registration, success)
    return false unless success

    user = user_service.create_user(_user_params(customer, params))
    user.errors.each { |attribute, error| registration.add_errors(attribute, error) }
    user.persisted?
  end

  def _process_payment(customer, params)
    status, payment_processor_customer_id = payment_service.process_payment(_payment_params(params))

    status && customer.update_attribute(:payment_processor_customer_id, payment_processor_customer_id)
  end

  def _customer_params(params)
    {
        name: params['customer_name'],
        contact_person_name: "#{params['first_name']} #{params['last_name']}",
        account_number: params['payment_email'],
        contact_email: params['payment_email'],
        subscription: params['subscription'],
        equipment_access: true,
        certification_access: true,
    }
  end

  def _user_params(customer, params)
    {
        first_name: params['first_name'],
        last_name: params['last_name'],
        password: params['password'],
        customer: customer,
        email: params['payment_email'],
        username: params['payment_email'],
        expiration_notification_interval: 'Weekly',
    }
  end

  def _registration_params(params)
    {
        subscription: params['subscription'],
        first_name: params['first_name'],
        last_name: params['last_name'],
        email: params['payment_email'],
        customer_name: params['customer_name'],
    }
  end

  def _payment_params(params)
    {
        payment_token: params['payment_token'],
        payment_email: params['payment_email'],
        subscription: params['subscription'],
    }
  end
end