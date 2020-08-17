require 'exeshnik/rails/controller/url_rewriting'
require 'exeshnik/rails/controller/redirects'

module Exeshnik
  module Rails

    # Rails application controller extension
    module Controller
      def self.included(base)
        base.class_eval do
          include Exeshnik::Rails::Controller::UrlRewriting
          include Exeshnik::Rails::Controller::Redirects

          helper_method(:exeshnik, :exe_params, :exe_signed_params, :params_without_exe_data,
            :current_exe_user, :exe_canvas?
          )

          helper Exeshnik::Rails::Helpers
        end
      end

      protected

      EXESHNIK_PARAM_NAMES = %w{ exe_user game_sid app_id auth_key request_key }

      RAILS_PARAMS = %w{ controller action }

      # Accessor to current application config. Override it in your controller
      # if you need multi-application support or per-request configuration selection.
      def exeshnik
        Exeshnik::Config.default
      end

      # A hash of params passed to this action, excluding secure information passed by EXE.RU
      def params_without_exe_data
        params.except(*EXESHNIK_PARAM_NAMES)
      end

      # params coming directly from EXE.RU
      def exe_params
        params.except(*RAILS_PARAMS)
      end

      # encrypted EXE.RU params
      def exe_signed_params
        if exe_params['game_sid'].present?
          encrypt_params(exe_params)
        else
          request.env["HTTP_SIGNED_PARAMS"] || request.params['signed_params'] || flash[:signed_params]
        end
      end

      # Accessor to current EXE.RU user. Returns instance of Exeshnik::User
      def current_exe_user
        @current_exe_user ||= fetch_current_exe_user
      end

      # Did the request come from canvas app
      def exe_canvas?
        exe_params['game_sid'].present? || request.env['HTTP_SIGNED_PARAMS'].present? || flash[:signed_params].present?
      end

      private

      def fetch_current_exe_user
        Exeshnik::User.from_exe_params(exeshnik, exe_params['game_sid'].present? ? exe_params : exe_signed_params)
      end

      def encrypt_params(params)
        encryptor = ActiveSupport::MessageEncryptor.new("secret_key_#{ exeshnik.app_id }_#{ exeshnik.app_secret }"[0..31])

        encryptor.encrypt_and_sign(params)
      end

      def decrypt_params(encrypted_params)
        encryptor = ActiveSupport::MessageEncryptor.new("secret_key_#{ exeshnik.app_id }_#{ exeshnik.app_secret }"[0..31])

        encryptor.decrypt_and_verify(encrypted_params)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        nil
      end
    end
  end
end