require "rom-repository"

module Site
  class Repo < ROM::Repository::Root
    include Deps[container: "database.rom"]

    struct_namespace Site::Entities
  end
end
