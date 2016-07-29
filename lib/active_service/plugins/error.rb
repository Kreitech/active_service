module ActiveService::Plugins::Error

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods

    def rescue_from(error_klass, &block)
      around do |o|
        begin
          o.call
        rescue error_klass => e
          instance_exec(e, &block) if block_given?
        end
      end
    end

  end

end
