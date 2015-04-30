require_relative 'active_service/version'
require_relative 'active_service/runner'
require_relative 'active_service/hooks'

module ActiveService

  def self.included(base)
    base.class_eval do
      include Runner
      include Hooks
    end
  end

end
