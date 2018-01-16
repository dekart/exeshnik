module Exeshnik
  module Rails
    module Helpers
      module JavascriptHelper

        # A helper to integrate EXE.RU JS Api to the current page. Generates a
        # JavaScript code that initializes Javascript client for the current application.
        #
        # @param &block A block of JS code to be inserted in addition to client initialization code.
        def exe_connect_js(&block)
          extra_js = capture(&block) if block_given?

          init_js = <<-JAVASCRIPT
            var options = {
              'showInviteFriends': 'exeApiCallback',
              'showRequestBox': 'exeApiCallback',
              'showPublishBox': 'exeApiCallback',
              'showOrderBox': 'exeApiCallback',
              'users.get': 'exeApiCallback',
              'friends.getAppUsers': 'exeApiCallback',
              'friends.get': 'exeApiCallback'
            };
            var exeApi = new ExeRuApi(options);
          JAVASCRIPT

          js_url = "//exe.ru/assets/js/api.js"

          js = <<-CODE
            <script src="#{ js_url }" type="text/javascript"></script>
          CODE

          js << <<-CODE
            <script type="text/javascript">
              if(typeof ExeRuApi !== 'undefined') {
                #{ init_js }
              }
              #{ extra_js }
            </script>
          CODE

          js = js.html_safe

          if block_given? && ::Rails::VERSION::STRING.to_i < 3
            concat(js)
          else
            js
          end
        end
      end
    end
  end
end
