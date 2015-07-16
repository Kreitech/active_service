require 'spec_helper'

module ActiveService

  describe Runner do

    describe 'operations' do

      let(:runned) {
        build_runned do
          operation :hello do
            'hello'
          end
        end
      }

      it 'runs the block' do
        expect(runned.hello).to eq('hello')
      end

      context 'when using #run_operation' do

        it 'runs the block' do
          expect(runned.run_operation :hello).to eq('hello')
        end

      end

    end

    describe 'pipes' do

      let(:runned) {
        build_runned do
          pipe :hello do |x|
            x << 'l'
          end

          pipe :hello do |x|
            x << 'o'
          end

          operation :hello do
            'hel'
          end

        end
      }

      it 'calls the pipe blocks' do
        expect(runned.hello).to eq('hello')
      end

    end

  end

end
