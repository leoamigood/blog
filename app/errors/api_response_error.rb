# frozen_string_literal: true

class ApiResponseError < StandardError
  attr_accessor :title, :detail, :code, :field, :status

  def initialize(title:, status:, code: nil, detail: nil, field: nil)
    super([ title, detail ].compact.join(": "))

    self.title = title
    self.code = code.presence || title.dup.force_encoding("UTF-8").parameterize(separator: "_")
    self.detail = detail
    self.field = field
    self.status = status
  end

  def to_jsonapi
    {
      status: status,
      title:  title,
      code:   code,
      detail: detail,
      source: ({ pointer: "/data/attributes/#{field.to_s.camelize(:lower)}" } if field.present?)
    }.compact
  end

  def self.from_error(error = nil, status = nil) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    case error
    when ApiResponseError
      error
    when ActiveRecord::RecordNotFound
      ApiResponseError.new(
        title:  "Record not found",
        status: 404,
        detail: "#{error.model.humanize} not found",
        code:   "#{error.model.underscore}_not_found"
      )
    when ActiveRecord::RecordInvalid
      error.record.errors.map do |model_error|
        ApiResponseError.new(
          field:  model_error.attribute.to_s,
          title:  "Invalid attribute",
          code:   "#{error.record.model_name.to_s.underscore}_invalid",
          detail: model_error.full_message,
          status: 422
        )
      end
    when StateMachines::InvalidTransition
      ApiResponseError.new(
        field:  error.machine.attribute,
        title:  "Invalid transition",
        code:   "#{error.machine.owner_class.to_s.underscore}_invalid_transition",
        detail: error.message,
        status: 422
      )
    when ActiveModel::Error
      error.errors.map do |model_error|
        ApiResponseError.new(
          field:  model_error.attribute.to_s,
          title:  "Invalid attribute",
          detail: model_error.full_message,
          status: 422,
          code:   "#{model_error.attribute}_invalid"
        )
      end
    when ServiceError
      ApiResponseError.new(title: error.title, detail: error.detail, code: error.code, status: 422, field: error.field)
    when String
      ApiResponseError.new(title: error, status: 422)
    when Dry::Validation::MessageSet
      error.map do |item|
        ApiResponseError.new(
          title:  "Invalid parameter",
          detail: "Invalid #{item.path.join(', ')} parameter, #{item.text}",
          status: 422
        )
      end
    when ActionPolicy::Unauthorized
      ApiResponseError.new(title: "Access denied.", code: :forbidden, status: 403)
    when ApiErrors::APIError
      from_status(502, error.message)
    when JSONAPI::Parser::InvalidDocument
      ApiResponseError.new(
        title:  "Invalid json-api object",
        detail: error.message,
        status: 422,
        code:   "invalid_json_api_object"
      )
    else
      if status
        from_status(status, error&.message)
      else
        from_status(500, error&.message)
      end
    end
  end

  # @param [Integer] status
  def self.from_status(status, message = nil)
    detail = Rails.env.local? ? message : nil

    ApiResponseError.new(title: Rack::Utils::HTTP_STATUS_CODES[status], status: status, detail:)
  end

  private_class_method :from_status
end
