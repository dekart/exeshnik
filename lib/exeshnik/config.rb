module Exeshnik
  class Config
    attr_accessor :config

    class << self
      # A shortcut to access default configuration stored in RAILS_ROOT/config/exeshnik.yml
      def default
        @@default ||= self.new(load_default_config_from_file)
      end

      def load_default_config_from_file
        config_data = YAML.load(
          ERB.new(
            File.read(::Rails.root.join("config", "exeshnik.yml"))
          ).result
        )[::Rails.env]

        raise NotConfigured.new("Unable to load configuration for #{ ::Rails.env } from config/exeshnik.yml") unless config_data

        config_data
      end
    end

    def initialize(options = {})
      self.config = options.to_options
    end

    # Defining methods for quick access to config values
    %w{app_id app_secret callback_domain}.each do |attribute|
      class_eval %{
        def #{ attribute }
          config[:#{ attribute }]
        end
      }
    end

    # URL of the application canvas page
    def canvas_page_url(protocol)
      "#{ protocol }exe.ru/app#{ app_id }"
    end

    # Application callback URL
    def callback_url(protocol)
      protocol + callback_domain
    end
  end
end