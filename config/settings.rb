# frozen_string_literal: true

module Site
  class Settings < Hanami::Settings
    setting :import_dir, constructor: Types::String
    setting :export_dir, constructor: Types::String

    setting :site_name, constructor: Types::String
    setting :site_author, constructor: Types::String
    setting :site_url, constructor: Types::String
  end
end
