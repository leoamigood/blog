# frozen_string_literal: true

class SerializableComment < BaseSerializable
  type "comments"

  attributes :content

  belongs_to :post
end
