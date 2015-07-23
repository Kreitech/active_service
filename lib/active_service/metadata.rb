module ActiveService

  module Metadata

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods

      def operations_metadata
        instance = new
        metadata = []

        operations.each do |o|
          operation = { name: o }

          operation[:parameters] = instance.method(o).parameters.map { |type, name|
            { name: name, type: type, required: (type == :keyreq || type == :req) }
          }

          metadata << operation
        end

        metadata
      end

    end

  end

end
