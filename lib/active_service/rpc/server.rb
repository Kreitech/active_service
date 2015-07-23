require 'grape'

require_relative 'parser'

class ActiveService::RPC::Server < Grape::API

  def initialize(services = [])
    @@services = services.map(&:to_s)

    super()
  end

  def self.services
    @@services
  end

  # We only accept JSON as content/type
  format :json

  resource :services do
    get do
      # service_classes.map(&:operations_metadata)
    end

    after_validation do
      # Find the service and get the class
      service_name = ActiveService::RPC::Server.services.find { |x| x == params[:class_name] }
      @service = Object.const_get(service_name)
    end

    params do
      requires :operation, type: String, desc: 'The operation to be called.'
      optional :parameters, type: Hash, desc: 'The operation parameters.'
    end

    post '/:class_name/execute' do
      payload = ActiveService::RPC::Parser.new(@service, params).operation_payload

      @service.run_operation(*payload)
    end
  end

end
