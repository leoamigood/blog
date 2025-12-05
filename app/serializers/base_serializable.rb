# frozen_string_literal: true

class BaseSerializable < JSONAPI::Serializable::Resource
  extend JSONAPI::Serializable::Resource::ConditionalFields
  extend JSONAPI::Serializable::Resource::KeyFormat

  key_format ->(key) { key.to_s.camelize(:lower) }
end
