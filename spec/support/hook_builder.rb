module HookBuilder

  def build_hooked(&block)
    hooked = Class.new

    hooked.class_eval do
      include ActiveService::Hooks

      attr_reader :steps

      def initialize
        @steps = []
      end

      def execute(*_args)
        self.class.run_before_hooks(self)
        self.class.run_around_hooks(self) { process }
        self.class.run_after_hooks(self)

        @steps
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
