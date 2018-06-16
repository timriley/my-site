require "site/import"
require "site/view/controller"
require "site/view/parts/talk"

module Site
  module Views
    class Speaking < View::Controller
      include Import["repos.talk_repo"]

      configure do |config|
        config.template = "speaking"
      end

      expose :talks, as: View::Parts::Talk do
        talk_repo.all
      end
    end
  end
end
