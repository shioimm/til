Toycol::Protocol.define(:ruby) do
  using Module.new {
    refine String do
      def get
        Protocol.request.path do |message|
          /['"](?<path>.+)['"]/.match(message)[:path]
        end

        Protocol.request.http_method { |_| "GET" }
      end
    end
  }

  request_message = self.instance_variable_get :@request_message
  instance_eval request_message
end
