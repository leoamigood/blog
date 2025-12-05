# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      include JsonApiRenderable
      include HandleError

      deserializable_resource(:resource, class: ::BaseDeserializable, unless: -> { params["_jsonapi"].blank? })
    end
  end
end
