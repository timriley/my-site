source "https://rubygems.org"

ruby "3.2.2"

# App framework
gem "hanami", github: "hanami/hanami", branch: "main"
gem "hanami-assets", github: "hanami/assets", branch: "main"
gem "hanami-cli", github: "hanami/cli", branch: "main"
gem "hanami-controller", github: "hanami/controller", branch: "main"
gem "hanami-router", github: "hanami/router", branch: "main"
gem "hanami-utils", github: "hanami/utils", branch: "main"
gem "hanami-view", github: "hanami/view", branch: "main"
gem "pry"

# Database
gem "rom", "~> 5.0"
gem "rom-sql", "~> 3.2"
gem "sqlite3"

# Core app utilities
gem "dotenv"
gem "dry-core"
gem "dry-monads"
gem "dry-types"

# Views
gem "builder"
gem "slim"

# Static content handling
gem "commonmarker"
gem "front_matter_parser"
gem "transproc"

group :cli, :development, :test do
  gem "hanami-reloader", github: "hanami/reloader", branch: "main"
end

group :development do
  gem "puma"
end

group :development, :test do
  gem "break"
  gem "foreman"
  gem "guard-puma"
end
