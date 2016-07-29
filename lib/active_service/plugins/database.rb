module ActiveService::Plugins::Database

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods

    def run_in_transaction
      around do |o|
        ActiveRecord::Base.transaction do
          o.call
        end
      end
    end

  end

end
