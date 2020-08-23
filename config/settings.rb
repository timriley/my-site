# frozen_string_literal: true

require "site/types"

Hanami.application.settings do
  setting :import_dir, Site::Types::String
  setting :export_dir, Site::Types::String

  setting :assets_precompiled, Site::Types::Params::Bool
  setting :assets_server_url, Site::Types::String.optional.default(nil)

  setting :site_name, Site::Types::String
  setting :site_author, Site::Types::String
  setting :site_url, Site::Types::String
end
