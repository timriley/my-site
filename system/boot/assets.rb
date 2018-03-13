Site::Container.boot :assets do |site|
  init do
    require "site/assets"
  end

  start do
    use :settings

    assets =
      if site[:settings].assets_precompiled
        Site::Assets::Precompiled.new(site[:settings].export_dir)
      else
        Site::Assets::Served.new(site[:settings].assets_server_url)
      end

    register "assets", assets
  end
end
