require_relative 'entity_switcher'

class HostRouter

  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    case request.host
    when Rails.application.config.admin_address
      Admin::Engine.call env
    when Rails.application.config.assets_address
      @app.call env
    else
      EntitySwitcher.new(@app).call env
    end
  end

end
