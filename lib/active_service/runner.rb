module ActiveService

  module Runner

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstaceMethods
        include Hooks
      end
    end

    module ClassMethods

      def pipe(*args, &block)
        block = ->(*ops) { send(args.first, *ops) } if args.first.is_a? Symbol

        pipe_blocks.push(block)
      end

      def pipe_blocks
        @pipe_blocks ||= []
      end

      def rescue_blocks
        @rescue_blocks ||= {}
      end

    end

    module InstaceMethods

      def execute(*args)
        run_hooks_and_operation(*args)
      end

      def run_pipes(result)
        transformed_result = result

        self.class.pipe_blocks.each do |block|
          transformed_result = block.call(transformed_result)
        end

        transformed_result
      end

      def run_hooks_and_operation(*args)
        self.class.run_before_hooks(self, *args)

        result = self.class.run_around_hooks(self) do
          operation(*args)
        end

        self.class.run_after_hooks(self, *args)

        run_pipes(result)
      end

    end

  end

end
