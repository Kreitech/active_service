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

      def method_missing(sym, *args, &block)
        obj = self.new

        skip = respond_to?(sym) || obj.respond_to?(sym) || !operations.key?(sym)

        super(sym, *args, &block) if skip

        obj.run_method(sym, *args, &block)
      end

      def rescue_operation(operation, *args, &block)
        options = extract_options! *args

        if options[:with]
          block = lambda { |*ops|
            send(options[:with], *ops)
          }
        end

        rescue_blocks[operation] = { block: block }.merge(options)
      end

      def pipe(operation_name, *args, &block)
        options = args.last.is_a?(::Hash) ? args.pop : {}

        if args.first.is_a? Symbol
          block = lambda { |*ops|
            send(args.first, *ops)
          }
        end

        pipe_blocks(operation_name).push(block)
      end

      def operation(name, &block)
        operations[name] = block
      end

      def operations
        @operations ||= {}
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
            self.instance_exec(*(args << e), &rescue_options[:block])
          end
        else
          run_hooks_and_operation(sym, *args, &block)
        end

      end

      def run_pipes(operation_name, result)
        transformed_result = result

        self.class.pipe_blocks(operation_name).each do |block|
          transformed_result = block.call(result)
        end

        transformed_result
      end

      def run_hooks_and_operation(sym, *args, &block)
        self.class.run_before_hooks(self, sym, *args)

        result = self.class.run_around_hooks(self, sym) do
          self.class.operations[sym].call(*args)
        end

        self.class.run_after_hooks(self, sym, *args)

        run_pipes(sym, result)
      end

    end

  end

end
