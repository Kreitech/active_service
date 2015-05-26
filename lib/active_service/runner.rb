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

    end

    module InstaceMethods

      def run_method(sym, *args, &block)
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
