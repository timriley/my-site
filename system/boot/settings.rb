Static::Container.boot :settings, from: :system do
  before :init do
    require "static/types"
  end

  settings do
    # Settings go here
  end
end
