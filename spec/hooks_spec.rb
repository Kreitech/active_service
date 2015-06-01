require 'spec_helper'

module ActiveService

  describe Hooks do

    context 'when using around hook' do

      context 'when using block api' do

        let(:hooked) {
          build_hooked do
            around :process do |o|
              steps << :pre
              o.call
              steps << :post
            end
          end
        }

        it 'calls the around block' do
          expect(hooked.process).to eq([:pre, :process, :post])
        end

      end

      context 'when using block api' do

        let(:hooked) {
          build_hooked do
            around :process, :post

            def post(operation)
              steps << :pre
              operation.call
              steps << :post
            end
          end
        }

        it 'calls the around method' do
          expect(hooked.process).to eq([:pre, :process, :post])
        end

      end

    end

    context 'when using before hook' do

      context 'when using block api' do

        let(:hooked) {
          build_hooked do
            before :process do
              steps << :pre
            end
          end
        }

        it 'calls the before block' do
          expect(hooked.process).to include(:pre)
        end

      end

      context 'when using block api' do

        let(:hooked) {
          build_hooked do
            before :process, :pre

            def pre
              steps << :pre
            end
          end
        }

        it 'calls the method' do
          expect(hooked.process).to include(:pre)
        end

      end

    end

  end

  context 'when using after hook' do

    context 'when using block api' do

      let(:hooked) {
        build_hooked do
          after :process do
            steps << :post
          end
        end
      }

      it 'calls the after block' do
        expect(hooked.process).to include(:post)
      end

    end

    context 'when using block api' do

      let(:hooked) {
        build_hooked do
          after :process, :post

          def post
            steps << :post
          end
        end
      }

      it 'calls the method' do
        expect(hooked.process).to include(:post)
      end

    end

  end

end
