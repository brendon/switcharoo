module Admin
  class Engine < ::Rails::Engine
    isolate_namespace Admin
    config.assets.precompile += %w( admin_manifest.js )
  end
end
