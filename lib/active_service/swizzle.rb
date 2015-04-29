module ActiveService

  module Swizzle
    SWIZZLE_PREFIX = 'active_service'

    def method_added(method_name)
      return if is_hook_method?(method_name) || is_hook_defined?(method_name)

      alias_method  swizzle_name(method_name), method_name

      remove_method method_name
    end

    def swizzle_name(method_name)
      "#{SWIZZLE_PREFIX}_#{method_name}"
    end

    def is_hook_method?(method_name)
      /#{SWIZZLE_PREFIX}/.match(method_name.to_s)
    end

    def is_hook_defined?(method_name)
      method_defined?("#{SWIZZLE_PREFIX}_#{method_name}")
    end

  end

end
