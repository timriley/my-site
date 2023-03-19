require "rom/repository/root"
require "site/entities"

module Site
  class Repo < ROM::Repository::Root
    include Import[container: "database.rom"]

    struct_namespace Entities
  end
end
