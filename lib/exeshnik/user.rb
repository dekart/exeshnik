module Exeshnik
  class User
    class UnsupportedAlgorithm < StandardError; end
    class InvalidSignature < StandardError; end

    class << self
      # Creates an instance of Exeshnik::User using application config and request parameters
      def from_exe_params(config, params)
        params = decrypt(config, params) if params.is_a?(String)

        return unless params && params['exe_user'] && signature_valid?(config, params)

        new(params)
      end

      def decrypt(config, encrypted_params)
        encryptor = ActiveSupport::MessageEncryptor.new("secret_key_#{config.app_id}_#{config.app_secret}")

        encryptor.decrypt_and_verify(encrypted_params)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        ::Rails.logger.error "\nError while decoding exe.ru params: \"#{ encrypted_params }\""

        nil
      end

      def signature_valid?(config, params)
        !params['auth_key'].blank? && params['auth_key'] == auth_key(config, params)
      end

      def auth_key(config, params)
        Digest::MD5.hexdigest(
          [config.app_id, params['exe_user'], config.app_secret].join('_')
        )
      end
    end

    def initialize(options = {})
      @options = options
    end

    def authenticated?
      access_token && !access_token.empty?
    end

    def uid
      @options['exe_user'].to_i
    end

    def access_token
      @options['game_sid']
    end
  end
end
