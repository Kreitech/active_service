module ActiveService

  module Hooks

    def before(*args, &block)
      options = extract_options! *args

      if args.first.is_a? Symbol
        block = lambda { |*ops|
          send(args.first, *ops)
        }
      end

      hook = { block: block }.merge options
      before_hooks.push(hook)
    end

    def after(*args, &block)
      options = extract_options! *args

      hook = { block: block }.merge options
      after_hooks.unshift(hook)
    end

    def before_hooks
      @before_hooks ||= []
    end

    def after_hooks
      @after_hooks ||= []
    end

    def run_before_hooks(*args)
      before_hooks.each { |h| run_hook(h, *args) }
    end

    def run_after_hooks(*args)
      after_hooks.each { |h| run_hook(h, *args) }
    end

    def run_hook?(hook, sym)
      only_method?(hook, sym)
    end

    def only_method?(hook, method_name)
      only_methods = hook[:only]
      sym          = method_name.to_sym

      (only_methods == sym) || (only_methods.is_a?(Array) && only_methods.include?(sym))
    end

    def except_method?(hook, method_name)
      only_methods = hook[:except]
      sym          = method_name.to_sym

      (only_methods != sym) || (only_methods.is_a?(Array) && !only_methods.include?(sym))
    end

    def run_hook(hook, *args)
      method_name = args.first

      return unless (!hook.has_key?(:only)   || only_method?(hook, method_name)) &&
                    (!hook.has_key?(:except) || except_method?(hook, method_name))

      instance_exec(nil, &hook[:block])
    end

    def extract_options!(*args)
      args.last.is_a?(::Hash) ? args.pop : {}
    end

  end

end

