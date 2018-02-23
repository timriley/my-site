begin
  require "byebug"
rescue LoadError
end

require_relative "../lib/static/container"

Static::Container.finalize!
