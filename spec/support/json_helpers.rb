# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body).with_indifferent_access
    rescue JSON::ParserError
      {}
    end
  end
end
