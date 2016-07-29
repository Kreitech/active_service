module ActiveService

  module Hooks

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods

      def before_hooks
        @before_hooks ||= []
      end

      def after_hooks
        @after_hooks ||= []
      end

      def around_hooks
        @around_hooks ||= []
      end

      def add_hook(type, *args, &block)
        blocks = [block].compact

        blocks << ->(*ops) { send(args.first, *ops) } if args.first.is_a? Symbol

        if args.first.is_a? Array
          args.first.each do |method|
            blocks << lambda do |*ops|
              send(method, *ops)
            end
          end
        end

        blocks.reverse.each do |b|
          send("#{type}_hooks").push(b)
        end
      end

      def before(*args, &block)
        add_hook(:before, *args, &block)
      end

      def after(*args, &block)
        add_hook(:after, *args, &block)
      end

      def around(*args, &block)
        add_hook(:around, *args, &block)
      end

      def run_before_hooks(obj, *args)
        before_hooks.reverse.each { |hook| run_hook(hook, obj, *args) }
      end

      def run_after_hooks(obj, *args)
        after_hooks.reverse.each { |hook| run_hook(hook, obj, *args) }
      end

      def run_around_hooks(obj, &block)
        around_hooks.inject(block) do |chain, hook|
          proc { run_hook(hook, obj, chain) }
        end.call
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
