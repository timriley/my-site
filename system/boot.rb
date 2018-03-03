begin
  require "byebug"
rescue LoadError
end

require_relative "../system/site/container"

Site::Container.finalize!
