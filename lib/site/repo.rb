require "rom/repository/root"
require "site/import"
require "site/entities"

module Site
  class Repo < ROM::Repository::Root
    include Import.args["database.rom"]

    struct_namespace Entities
  end
end
