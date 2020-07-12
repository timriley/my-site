Site::Container.boot :settings, from: :system do
  before :init do
    require "site/types"
  end

  settings do
    key :import_dir, Site::Types::String
    key :export_dir, Site::Types::String

    key :assets_precompiled, Site::Types::Params::Bool
    key :assets_server_url, Site::Types::String.optional.default(nil)

    key :site_name, Site::Types::String
    key :site_author, Site::Types::String
    key :site_url, Site::Types::String
  end
end
