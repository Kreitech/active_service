require 'spec_helper'
require 'active_service/rpc'

describe ActiveService::RPC::Server do

  include Rack::Test::Methods

  class ::A
    include ActiveService

    operation :hello do
      { message: 'hello' }
    end

  end

  def app
    ActiveService::RPC::Server.new([A])
  end

  context '#POST /:service_name/execute' do

    let(:params) { {} }

    context 'when service exists' do

      subject { post '/services/A/execute', params }

      context 'when operation exists' do

        before { params.merge!(operation: 'hello') }

        it { should match_json 'message' => 'hello' }

      end

    end

  end

end
