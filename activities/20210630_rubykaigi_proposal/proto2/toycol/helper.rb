module Toycol
  module Helper
    private

      def safe_execution
        safe_executionable_tp.enable { yield }
      end

      def safe_executionable_tp
        @safe_executionable_tp ||= TracePoint.new(:script_compiled) { |tp|
          if tp.binding.receiver == @protocol && tp.method_id.to_s.match?(unauthorized_methods_regex)
            raise Toycol::UnauthorizedMethodError, <<~ERROR
              - Unauthorized method was called!
              You can't use methods that may cause injections in your protocol.
              Ex. Kernel.#eval, Kernel.#exec, Kernel.#require and so on.
            ERROR
          end
        }
      end

      def unauthorized_methods_regex
        /(.*eval|.*exec|`.+|%x\(|system|open|require|load)/
      end
  end
end
