require 'spec_helper'
require 'active_service/plugins/error'

describe ActiveService::Plugins::Error do

  context 'when the operation raises a catched error' do

    context 'when no block is provided' do

      let(:hooked) do
        build_runned do
          include ActiveService::Plugins::Error

          rescue_from StandardError

          def operation
            raise StandardError
          end
        end
      end

      it 'should not raise an error' do
        expect { hooked.new.execute }.not_to raise_error
      end
    end

    context 'when a block is provided' do

      let(:hooked) do
        build_runned do
          include ActiveService::Plugins::Error

          attr_accessor :passed

          rescue_from StandardError do |_e|
            self.passed = true
          end

          def operation
            raise StandardError
          end
        end
      end

      it 'should call the provided block' do
        hooked_instance = hooked.new
        hooked_instance.passed = false

        expect { hooked_instance.execute }.to change { hooked_instance.passed }.from(false).to(true)
      end

    end

  end

  context 'when the operation raises a uncatched error' do

    let(:hooked) do
      build_runned do
        include ActiveService::Plugins::Error

        rescue_from NotImplementedError

        def operation
          raise StandardError
        end
      end
    end

    it 'should raise a StandardError' do
      expect { hooked.new.execute }.to raise_error StandardError
    end

  end

end
