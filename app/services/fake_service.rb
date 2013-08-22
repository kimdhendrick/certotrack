class FakeService
  attr_accessor :received_messages, :received_params

  def method_missing(m, *args, &block)
    _record_received_params(m.to_sym, args)
  end

  def received_message
    @received_messages.first if @received_messages.count == 1
  end

  private

  def _record_received_params(message, params)
    @received_messages ||= []
    @received_messages << message
    @received_params = params
  end
end
