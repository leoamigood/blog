# frozen_string_literal: true

class SerializablePost < BaseSerializable
  type "posts"

  attributes :title, :content, :published
end
