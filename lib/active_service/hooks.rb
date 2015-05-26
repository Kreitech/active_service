module ActiveService

  module Hooks

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods

      %W(before after around).each do |type|
        class_eval %{
          def #{type}_hooks(action)
            @#{type}_hooks ||= {}

            @#{type}_hooks[action] ||= []
          end
        }
      end

      def add_hook(type, action, *args, &block)
        options = extract_options! *args

        if args.first.is_a? Symbol
          block = lambda { |*ops|
            send(args.first, *ops)
          }
        end

        send("#{type}_hooks",action).push(block)
      end

      def before(action, *args, &block)
        add_hook(:before, action, *args, &block)
      end

      def after(action, *args, &block)
        add_hook(:after, action, *args, &block)
      end

      def around(action, *args, &block)
        add_hook(:around, action, *args, &block)
      end

      def run_before_hooks(obj, action)
        before_hooks(action).each { |h| run_hook(h, obj, action) }
      end

      def run_after_hooks(obj, action)
        after_hooks(action).each { |h| run_hook(h, obj, action) }
      end

      def run_around_hooks(obj, action, &block)
        around_hooks(action).inject(block) { |chain, hook|
          proc { run_hook(hook, obj, chain) }
        }.call
      end

      def run_hook(hook, obj, *args)
        obj.instance_exec(*args, &hook)
      end

      def extract_options!(*args)
        args.last.is_a?(::Hash) ? args.pop : {}
      end

    end

  end

end

