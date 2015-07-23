module ActiveService

  module RPC

    class Parser

      attr_reader :service, :request_params

      def initialize(service, request_params)
        @service = service
        @request_params = request_params
      end

      def operation
        @operation ||= request_params[:operation].to_sym
      end

      def args
        @args ||= []
      end

      def options
        @options ||= {}
      end

      def parameters?
        request_params.key? :parameters
      end

      def operation_payload
        return [operation] unless parameters?

        operations_metadata = service.operations_metadata.find { |x| x[:name] == operation }

        build_args(operations_metadata)
      end

      def build_args(operations_metadata)
        operations_metadata[:parameters].each do |parameter|
          name = parameter[:name]
          type = parameter[:type]

          if type == :req
            args << request_params[:parameters][name]
          elsif type == :keyreq
            options.merge!(name => request_params[:parameters][name])
          end
        end

        args << options unless options.empty?
        args.unshift(operation)
      end

    end

  end

end
