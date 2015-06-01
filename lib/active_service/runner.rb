module ActiveService

  module Runner

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstaceMethods
      end
    end

    module ClassMethods

      def method_missing(sym, *args, &block)
        obj = self.new

        super(sym, *args, &block) unless obj.respond_to?(sym)

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

      def run_hooks_and_operation(sym, *args, &block)
        self.class.run_before_hooks(self, sym, *args)

        result = self.class.run_around_hooks(self, sym) do
          send(sym, *args, &block)
        end

        self.class.run_after_hooks(self, sym, *args)

        result
      end

    end

  end

end
