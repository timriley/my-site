Static::Container.boot :database, namespace: true do |system|
  init do
    require "sequel"
    require "rom"
    require "rom/sql"

    use :settings

    Sequel.database_timezone = :utc
    Sequel.application_timezone = :local

    config = ROM::Configuration.new(
      :sql,
      "sqlite::memory",
      extensions: %i[error_sql],
    )

    config.plugin :sql, relations: :auto_restrictions

    register "config", config
    register "connection", config.gateways[:default].connection
  end

  start do
    config = container["database.config"]
    config.auto_registration system.root.join("lib/database")

    config.gateways[:default].auto_migrate!(config, inline: true)

    register "rom", ROM.container(config)

    # require "static/database/migrate"
    # migrate = Static::Database::Migrate.new
    # migrate.(system.config.root.join("config/schema.yml"), rom: rom)
  end
end
