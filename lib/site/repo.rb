require "rom-repository"
require "site/entities"

module Site
  class Repo < ROM::Repository::Root
    include Deps[container: "database.rom"]

    struct_namespace Entities
  end
end
