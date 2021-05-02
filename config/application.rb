require_relative "boot"

require "rails/all"

require_relative 'extensions/mysql2adapter'
require_relative 'middleware/host_router'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Switcharoo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.force_ssl = true

    config.middleware.use HostRouter

    # These address configurations would normally be in environemnt-specific
    # config files but are here for convenience in this example.
    config.admin_address = 'admin.switcharoo.test'
    config.assets_address = 'assets.switcharoo.test'

    config.action_controller.asset_host = "https://#{config.assets_address}"
    config.action_mailer.asset_host = "https://#{config.assets_address}"
  end
end
