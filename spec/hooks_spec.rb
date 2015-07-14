require 'spec_helper'

module ActiveService

  describe Hooks do

    context 'when using around hook' do

      context 'when using block' do

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

      context 'when using symbols' do

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

      context 'when using Array of symbols' do

        let(:hooked) {
          build_hooked do
            around :process, [:post1, :post2]

            def post1(operation)
              steps << :pre1
              operation.call
              steps << :post1
            end

            def post2(operation)
              steps << :pre2
              operation.call
              steps << :post2
            end
          end
        }

        it 'calls the around method' do
          expect(hooked.process).to eq([:pre1, :pre2, :process, :post2, :post1])
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

      context 'when using symbol' do

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

      context 'when using Array of symbols' do

        let(:hooked) {
          build_hooked do
            before :process, [:post1, :post2]

            def post1
              steps << :pre1
            end

            def post2
              steps << :pre2
            end
          end
        }

        it 'calls the before methods' do
          expect(hooked.process).to eq([:pre1, :pre2, :process])
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

    context 'when using symbol' do

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

    context 'when using Array of symbols' do

      let(:hooked) {
        build_hooked do
          after :process, [:post1, :post2]

          def post1
            steps << :post1
          end

          def post2
            steps << :post2
          end
        end
      }

      it 'calls the after methods' do
        expect(hooked.process).to eq([:process, :post1, :post2])
      end

    end

  end

end
