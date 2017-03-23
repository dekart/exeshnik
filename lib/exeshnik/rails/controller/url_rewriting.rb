require 'exeshnik/rails/helpers/url_helper'

module Exeshnik
  module Rails
    module Controller
      module UrlRewriting
        include Exeshnik::Rails::Helpers::UrlHelper

        def self.included(base)
          base.class_eval do
            helper_method(:exe_canvas_page_url, :exe_callback_url)
          end
        end

        protected

        # A helper to generate an URL of the application canvas page URL
        #
        # @param protocol A request protocol, should be either 'http://' or 'https://'.
        #                 Defaults to current protocol.
        def exe_canvas_page_url(protocol = nil)
          exeshnik.canvas_page_url(protocol || request.protocol)
        end

        # A helper to generate an application callback URL
        #
        # @param protocol A request protocol, should be either 'http://' or 'https://'.
        #                 Defaults to current protocol.
        def exe_callback_url(protocol = nil)
          exeshnik.callback_url(protocol || request.protocol)
        end
      end
    end
  end
end
