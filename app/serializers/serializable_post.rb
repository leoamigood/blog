# frozen_string_literal: true

class SerializablePost < BaseSerializable
  type "posts"

  attributes :title, :content, :published

  has_many :comments
end
