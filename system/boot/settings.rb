Site::Container.boot :settings, from: :system do
  before :init do
    require "site/types"
  end

  settings do
    key :import_dir, Site::Types::Strict::String
    key :export_dir, Site::Types::Strict::String

    key :site_name, Site::Types::Strict::String
    key :site_author, Site::Types::Strict::String
    key :site_url, Site::Types::Strict::String
  end
end
