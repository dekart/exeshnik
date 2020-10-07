module Exeshnik
  class Engine < ::Rails::Engine
    initializer "exeshnik.middleware" do |app|
      app.middleware.insert_before(::Rack::Head, Exeshnik::Middleware)
    end

    initializer "exeshnik.controller_extension" do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, Exeshnik::Rails::Controller)
      end
    end
  end
end
