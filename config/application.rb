require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyOnRailsTournamentSystem
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end

  ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| 
    html = %(<div class="has-error">#{html_tag})
    html += %(</div>)
    html.html_safe
  }
end
