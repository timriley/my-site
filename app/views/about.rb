module Site
  module Views
    class About < Site::View
      configure do |config|
        config.template = "about"
      end
    end
  end
end
