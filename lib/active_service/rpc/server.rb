require 'grape'

class ActiveService::RPC::Server < Grape::API

  def initialize(services = [])
    @@services = services.map { |x| x.to_s }

    super()
  end

  def self.services
    @@services
  end

  # We only accept JSON as content/type
  format :json

  helpers do
    def execute(on_service:, operation:, payload:)
      service_string = ActiveService::RPC::Server.services.find { |x| x == on_service }
      service_class = Object.const_get(service_string)

      payload = payload.to_h.map { |k,v| { k.to_sym => v } }.reduce(&:merge)
      service_class.run_operation(operation.to_sym, *[payload].compact)
    end

    def service_classes
       ActiveService::RPC::Server
        .services
        .map { |x| Object.const_get(x) }
    end

  end

  resource :services do

    get do
      service_classes.map { |x| x.operations_metadata }
    end

    params do
      requires :operation, type: String, desc: 'The operation to be called.'
      optional :payload, type: Hash, desc: 'The operation parameters.'
    end
    post '/:class_name/execute' do
      service_name = params[:class_name]
      operation = params[:operation]
      payload = params[:payload]

      execute(on_service: service_name, operation: operation, payload: payload)
    end

  end

end
