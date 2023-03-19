Site::Container.register_provider :settings, from: :dry_system do
  before :prepare do
    require "site/types"
  end

  settings do
    setting :import_dir, constructor: Site::Types::String
    setting :export_dir, constructor: Site::Types::String

    setting :assets_precompiled, constructor: Site::Types::Params::Bool
    setting :assets_server_url, constructor: Site::Types::String.optional.default(nil)

    setting :site_title, constructor: Site::Types::String
    setting :site_author, constructor: Site::Types::String
    setting :site_url, constructor: Site::Types::String
  end
end
