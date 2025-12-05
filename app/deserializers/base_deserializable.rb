# frozen_string_literal: true

class BaseDeserializable < JSONAPI::Rails::DeserializableResource
  key_format(&:underscore)
end
