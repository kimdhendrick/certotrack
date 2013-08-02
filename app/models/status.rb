module Status
  class Value
    attr_reader :value
    attr_reader :sort_order

    def initialize(value, sort_order)
      @value = value.dup.freeze
      @sort_order = sort_order
    end

    alias_method :to_s, :value
    alias_method :inspect, :value
  end

  VALID = Value.new('Valid', 0)
  WARNING = Value.new('Warning', 1)
  EXPIRED = Value.new('Expired', 2)
  RECERTIFY = Value.new('Recertify', 3)
  NA = Value.new('NA', 4)
end