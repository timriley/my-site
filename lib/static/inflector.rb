require "transproc/registry"
require "dry/inflector"
require "dry/core/cache"

module Static
  class Inflector
    extend Dry::Core::Cache

    attr_reader :backend

    def initialize
      @backend = Dry::Inflector.new.extend(Transproc::Registry)
    end

    def call(input, *fns)
      composed(*fns)[input]
    end
    alias_method :[], :call

    private

    def composed(*fns)
      fetch_or_store(fns.hash) { fns.map { |fn| backend[fn] }.reduce(:>>) }
    end
  end
end
