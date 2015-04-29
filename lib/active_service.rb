require_relative 'active_service/version'
require_relative 'active_service/swizzle'
require_relative 'active_service/hooks'

module ActiveService

  def self.included(base)
    base.class_eval do
      extend Swizzle
      extend Hooks
    end
  end

  def swizzle_name(method_name)
    self.class.swizzle_name(method_name)
  end

  def run_method(sym, *args, &block)
    self.class.run_before_hooks(sym)

    send(self.class.swizzle_name(sym), *args, &block)

    self.class.run_after_hooks(sym)
  end

  def method_missing(sym, *args, &block)
    super(sym, *args, &block) unless respond_to?(swizzle_name(sym))

    run_method(sym, *args, &block)
  end

end
