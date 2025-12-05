# frozen_string_literal: true

module Middleware
  class JsonApiErrors
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        response = @app.call(env)
      rescue StandardError => e
        return render_error(ApiResponseError.from_error(e))
      end

      status, headers, _body = response
      if status >= 400 && !headers["Content-Type"]&.include?("application/vnd.api+json") &&
         !env.dig("action_dispatch.request.path_parameters", :controller)&.start_with?("admin")
        exception = env["action_dispatch.exception"]
        return render_error(ApiResponseError.from_error(exception, status))
      end

      response
    end

    private

    def render_error(errors, status: nil)
      response = { errors: Array.wrap(errors).map(&:to_jsonapi) }

      [
        status || Array.wrap(errors).first.status,
        { "Content-Type" => "application/vnd.api+json" },
        [ response.to_json ]
      ]
    end
  end
end
