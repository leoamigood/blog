# frozen_string_literal: true

module HandleError
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :on_failure_result
    rescue_from ActiveRecord::RecordNotFound, with: :on_failure_result
    rescue_from JSONAPI::Parser::InvalidDocument, with: :on_failure_result
  end
end
