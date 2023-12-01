# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module Site
  class Action < Hanami::Action
    def generate
      view.()
    end
  end
end
