module ActiveService::Plugins

  require_relative 'plugins/database' if defined? ActiveRecord

end
