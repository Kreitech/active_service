require 'spec_helper'

describe ActiveService::Hooks do

  context 'when using around hook' do

    shared_context 'hooked with parent' do

      let(:hooked_parent) do
        build_hooked do
          around do |o|
            steps << :pre_parent
            o.call
            steps << :post_parent
          end
        end
      end

      let(:hooked) do
        klass = Class.new(hooked_parent)

        klass.class_eval do
          around do |o|
            steps << :pre_child
            o.call
            steps << :post_child
          end
        end

        klass
      end
    end

    context 'when using block' do

      context 'when there is a superclass' do

        include_context 'hooked with parent'

        it 'calls the parent and child around block' do
          expect(hooked.new.execute).to eq([:pre_child, :pre_parent, :process, :post_parent, :post_child])
        end

      end

      context 'when using block' do

        let(:hooked) do
          build_hooked do
            around do |o|
              steps << :pre
              o.call
              steps << :post
            end
          end
        end

        it 'calls the around block' do
          expect(hooked.new.execute).to eq([:pre, :process, :post])
        end
      end

    end

    context 'when using symbols' do

      let(:hooked) do
        build_hooked do
          around :post

          def post(operation)
            steps << :pre
            operation.call
            steps << :post
          end
        end
      end

      it 'calls the around method' do
        expect(hooked.new.execute).to eq([:pre, :process, :post])
      end

    end

    context 'when using Array of symbols' do

      let(:hooked) do
        build_hooked do
          around [:post1, :post2]

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

      end

      it 'calls the around method' do
        expect(hooked.new.execute).to eq([:pre1, :pre2, :process, :post2, :post1])
      end
    end

  end

  context 'when using before hook' do

    context 'when using block api' do

      let(:hooked) do
        build_hooked do
          before do |*_args|
            steps << :pre
          end
        end
      end

      it 'calls the before block' do
        expect(hooked.new.execute).to include(:pre)
      end
    end

    context 'when using symbol' do

      let(:hooked) do
        build_hooked do
          before :pre

          def pre(*_args)
            steps << :pre
          end
        end
      end

      it 'calls the method' do
        expect(hooked.new.execute).to include(:pre)
      end

    end

    context 'when using Array of symbols' do
      let(:hooked) do
        build_hooked do
          before [:post1, :post2]

          def post1(*_args)
            steps << :pre1
          end

          def post2(*_args)
            steps << :pre2
          end
        end

      end

      it 'calls the before methods' do
        expect(hooked.new.execute).to eq([:pre1, :pre2, :process])
      end
    end

  end

  context 'when using after hook' do

    context 'when using block api' do

      let(:hooked) do
        build_hooked do
          after do |*_args|
            steps << :post
          end
        end
      end

      it 'calls the after block' do
        expect(hooked.new.execute).to include(:post)
      end
    end

    context 'when using symbol' do
      let(:hooked) do
        build_hooked do
          after :post

          def post(*_args)
            steps << :post
          end
        end
      end

      it 'calls the method' do
        expect(hooked.new.execute).to include(:post)
      end
    end

    context 'when using Array of symbols' do
      let(:hooked) do
        build_hooked do
          after [:post1, :post2]

          def post1(*_args)
            steps << :post1
          end

          def post2(*_args)
            steps << :post2
          end
        end
      end

      it 'calls the after methods' do
        expect(hooked.new.execute).to eq([:process, :post1, :post2])
      end
    end

  end

end
