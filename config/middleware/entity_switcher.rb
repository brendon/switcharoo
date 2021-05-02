require 'addressable/uri'

class EntitySwitcher
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    current_entity = Entity.find_by_domain(request.host)

    # Ensure there is an entity registered against this host
    unless current_entity
      return ['404', {'Content-Type' => 'text/html'}, ["The domain name <strong>#{request.host}</strong> may be pointing to this server in error."]]
    end

    ActiveRecord::Base.connection.change_database!(current_entity[:database])

    Rails.logger.info("Host: #{request.host} | Database: #{current_entity[:database]}")

    @app.call env
  end

  private

  def domain_database_hash
    Rails.cache.fetch 'domain_database_hash' do
      Domain.includes(:entity).all.each_with_object({}) do |domain, result|
        result[domain.name] = { :domain_hash => domain.entity.domain_hash,
                                :disabled? => domain.entity.disabled?,
                                :primary_domain => domain.entity.domains.first.name }
      end
    end
  end

  def redirect_to(new_location)
    ['301', {'Content-Type' => 'text/html', 'location' => new_location}, ["Redirecting you to <a href=\"#{new_location}\">#{new_location}</a>."]]
  end

end
