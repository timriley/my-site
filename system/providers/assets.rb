Site::Container.register_provider :assets do
  prepare do
    require "site/assets"
  end

  start do
    assets =
      if target[:settings].assets_precompiled
        Site::Assets::Precompiled.new(target[:settings].export_dir)
      else
        Site::Assets::Served.new(target[:settings].assets_server_url)
      end

    register "assets", assets
  end
end
