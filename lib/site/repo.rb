require "rom/repository/root"
require "site/import"

module Site
  class Repo < ROM::Repository::Root
    include Import.args["database.rom"]
  end
end
