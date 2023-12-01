source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby "3.2.1"

gem "hanami", github: "hanami/hanami", branch: "main"
gem "hanami-assets", github: "hanami/assets", branch: "main"
gem "hanami-cli", github: "hanami/cli", branch: "main"
gem "hanami-controller", github: "hanami/controller", branch: "main"
gem "hanami-router", github: "hanami/router", branch: "main"
gem "hanami-utils", github: "hanami/utils", branch: "main"
gem "hanami-view", github: "hanami/view", branch: "main"

gem "builder", "~> 3.2"
gem "commonmarker", "~> 0.21.0"
gem "front_matter_parser", "~> 0.1", ">= 0.1.1"
gem "dotenv"
gem "dry-core"
gem "dry-inflector"
gem "dry-monads", "~> 1.0"
gem "dry-types", "~> 1.0"

gem "pry"
gem "rom", "~> 5.0"
gem "rom-sql", "~> 3.2"
gem "slim"
gem "sqlite3"
gem "transproc"

group :cli, :development, :test do
  gem "hanami-reloader", path: "~/Source/hanami/reloader"
end

group :development do
  gem "puma"
end

group :development, :test do
  gem "break"
  gem "foreman"
  gem "guard-puma"
end
