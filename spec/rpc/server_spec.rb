require 'spec_helper'
require 'active_service/rpc'

require 'json'

describe ActiveService::RPC::Server do

  include Rack::Test::Methods

  let(:params) { {} }

  class ::A

    include ActiveService

    operation :hello do
      { message: 'hello' }
    end

    operation :hello_with_params do |param1, param2|
      [param1, param2]
    end

  end

  def app
    ActiveService::RPC::Server.new([A])
  end

  context '#GET /services' do

    subject { get '/services', params }

    let(:operations_metadata) { {} }

    pending 'should match the operations metadata'

  end

  context '#POST /:service_name/execute' do

    context 'when using service A' do

      subject { post '/services/A/execute', params }

      context 'when using operation :hello' do

        before { params.merge!(operation: 'hello') }

        it { should match_json 'message' => 'hello' }

      end

      context 'when using operation :hello_with_params' do

        before { params.merge!(operation: 'hello_with_params', parameters: { param1: '1', param2: '2' }) }

        it { should match_json %w(1 2) }

      end

    end

  end

end
