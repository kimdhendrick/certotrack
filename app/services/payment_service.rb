class PaymentService
  def process_payment(params)
    customer = _create_customer(params)

    subscription = _create_subscription(customer, params)

    return subscription.present?, customer.try(:id)

  rescue Stripe::CardError => stripe_card_exception
    Rails.logger.error("Error processing subscription: #{stripe_card_exception}")
    return false, nil
  end

  private

  def _create_customer(params)
    Stripe::Customer.create(
        email: params[:payment_email],
        source: params[:payment_token]
    )
  end

  def _create_subscription(customer, params)
    return unless customer.present?

    customer.
        subscriptions.
        create(plan: params[:subscription])
  end
end