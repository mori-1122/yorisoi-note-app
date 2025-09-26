require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module YorisoiNote2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    if Rails.env.development? || Rails.env.test?
      Dotenv::Railtie.load
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.i18n.default_locale = :ja # 日本語にする
    config.action_dispatch.allow_browser = true
    config.action_mailer.default_url_options = { host: "localhost", port: 5000 }
    # Configuration for the application, engines, and railties goes here.
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    config.time_zone = "Tokyo" # タイムゾーンを東京に設定 録音機能で使用
    config.active_storage.variant_processor = :mini_magick
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_job.queue_adapter = :sidekiq
  end
end
