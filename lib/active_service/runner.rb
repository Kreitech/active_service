module ActiveService

  module Runner

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstaceMethods
        include Metadata
        include Hooks
      end
    end

    module ClassMethods

      def run_operation(operation_name, *args)
        new.run_method(operation_name, *args)
      end

      def method_missing(sym, *args, &block)
        super(sym, *args, &block) if respond_to?(sym) || !operations.include?(sym)

        new.run_method(sym, *args, &block)
      end

      def rescue_operation(operation, *_args, &block)
        block = ->(*ops) { send(options[:with], *ops) } if options[:with]

        rescue_blocks[operation] = { block: block }.merge(options)
      end

      def pipe(operation_name, *args, &block)
        block = ->(*ops) { send(args.first, *ops) } if args.first.is_a? Symbol

        pipe_blocks(operation_name).push(block)
      end

      def operation(name, &block)
        define_method name, &block

        operations << name
      end

      def operations
        @operations ||= []
      end

      def pipe_blocks(operation_name)
        @pipe_blocks ||= {}

        @pipe_blocks[operation_name] ||= []
      end

      def rescue_blocks
        @rescue_blocks ||= {}
      end

    end

    module InstaceMethods

      def run_method(sym, *args, &block)
        rescue_options = self.class.rescue_blocks[sym]

        if rescue_options
          begin
            run_hooks_and_operation(sym, *args, &block)
          rescue rescue_options[:from] => e
            instance_exec(*(args << e), &rescue_options[:block])
          end
        else
          run_hooks_and_operation(sym, *args, &block)
        end
      end

      def run_pipes(operation_name, result)
        transformed_result = result

        self.class.pipe_blocks(operation_name).each do |block|
          transformed_result = block.call(transformed_result)
        end

        transformed_result
      end

      def run_hooks_and_operation(sym, *args, &_block)
        self.class.run_before_hooks(self, sym, *args)

        result = self.class.run_around_hooks(self, sym) do
          send(sym, *args)
        end

        self.class.run_after_hooks(self, sym, *args)

        run_pipes(sym, result)
      end

    end

  end

end
