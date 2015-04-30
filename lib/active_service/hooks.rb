module ActiveService

  module Hooks

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods

      def before(action, *args, &block)
        options = extract_options! *args

        if args.first.is_a? Symbol
          block = lambda { |*ops|
            send(args.first, *ops)
          }
        end

        hook = { block: block }.merge options
        before_hooks(action).push(hook)
      end

      def after(action, *args, &block)
        options = extract_options! *args

        if args.first.is_a? Symbol
          block = lambda { |*ops|
            send(args.first, *ops)
          }
        end

        hook = { block: block }.merge options
        after_hooks(action).unshift(hook)
      end

      def before_hooks(action)
        @before_hooks ||= {}

        @before_hooks[action] ||= []
      end

      def after_hooks(action)
        @after_hooks ||= {}

        @after_hooks[action] ||= []
      end

      def run_before_hooks(obj, action)
        before_hooks(action).each { |h| run_hook(h, obj, action) }
      end

      def run_after_hooks(obj, action)
        after_hooks(action).each { |h| run_hook(h, obj, action) }
      end

      def run_hook(hook, obj, action)
        obj.instance_exec(&hook[:block])
      end

      def extract_options!(*args)
        args.last.is_a?(::Hash) ? args.pop : {}
      end

    end

  end

end

