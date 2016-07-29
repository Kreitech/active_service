require 'spec_helper'

describe ActiveService::Runner do
  describe 'operations' do
    let(:runned) do
      build_runned do
        def operation
          'hello'
        end
      end
    end

    it 'runs the block' do
      expect(runned.new.execute).to eq('hello')
    end
  end

  describe 'pipes' do
    let(:runned) do
      build_runned do
        pipe do |x|
          x << 'l'
        end

        pipe do |x|
          x << 'o'
        end

        def operation
          'hel'
        end
      end
    end

    it 'calls the pipe blocks' do
      expect(runned.new.execute).to eq('hello')
    end
  end
end
