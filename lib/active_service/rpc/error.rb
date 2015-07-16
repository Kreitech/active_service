
module ActiveService::RPC::Error

  class Base < StandardError

    def initialize(http_code = 422)
      @message = message
      @http_code = http_code
    end

    def to_json
      { error: { type: self.class.to_s, message: @message } }
    end

  end

  class ServiceNotFound < Base

    def initialize(http_code, service_name)
      @service_name = service_name

      super(http_code)
    end

    def message
      "The service #{service_name} was not found"
    end

  end

  class OperationNotFound < Base

    def initialize(http_code, operation_name)
      @operation_name = operation_name

      super(http_code)
    end

    def message
      "The operation #{operation_name} was not found"
    end

  end

end
