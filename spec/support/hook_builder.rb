module HookBuilder

  def build_hooked(&block)
    hooked = Class.new

    hooked.class_eval do
      include ActiveService::Hooks

      attr_reader :steps

      def initialize
        @steps = []
      end

      def self.process
        instance = new

        run_before_hooks(instance, :process)
        run_around_hooks(instance, :process) { instance.process }
        run_after_hooks(instance, :process)

        instance.steps
      end

      def process
        steps << :process
      end

    end

    hooked.class_eval(&block) if block
    hooked
  end

  def build_runned(&block)
    hooked = Class.new

    hooked.class_eval do
      include ActiveService::Runner
    end

    hooked.class_eval(&block) if block
    hooked
  end


end
