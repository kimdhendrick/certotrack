class Faker
  attr_accessor :received_messages, :received_params, :all_received_params

  def initialize(fake_return_value = nil)
    @fake_return_value = fake_return_value
  end

  def method_missing(m, *args, &block)
    _record_received_params(m.to_sym, args)
    @fake_return_value
  end

  def received_message
    return nil if @received_messages.nil?

    @received_messages.first if @received_messages.count == 1
  end

  private

  def _record_received_params(message, params)
    @received_messages ||= []
    @received_messages << message
    @received_params = params

    @all_received_params ||= []
    @all_received_params << params
  end
end
