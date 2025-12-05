# frozen_string_literal: true

module JsonApiRenderable
  def on_success_result(data, extra_options = {})
    render_serialized data, status: :ok, extra_options:
  end

  def on_failure_result(error)
    api_errors = Array.wrap(error).map { ApiResponseError.from_error(_1) }.flatten

    api_errors.any? { _1.status >= 500 } ? raise(error) : render_error(api_errors)
  end

  # @param [Array<ApiResponseError>, ApiResponseError] errors
  def render_error(errors)
    result = { errors: Array.wrap(errors).map(&:to_jsonapi) }

    response.headers["Content-Type"] = "application/vnd.api+json"

    render(json: result, status: Array.wrap(errors).first.status)
  end

  def render_serialized(data, status: :ok, extra_options: {})
    response = {
      jsonapi: data,
      status:,
      **rendering_options.merge(extra_options)
    }

    response = response.merge(paginated_response(data)) if data.is_a?(Enumerable) && pagination_enabled?(extra_options)
    render(response)
  end

  def pagination_enabled?(options = {})
    options.fetch(:rendering_options, {}).fetch(:paginate, true)
  end

  def paginated_response(data)
    data = Kaminari.paginate_array(data) if data.is_a?(Array)
    {
      jsonapi: data.page(paginate_params[:page]).per(paginate_params[:per_page]),
      meta:    serializer_options.fetch(:meta) {
        {
          page:     paginate_params[:page],
          per_page: paginate_params[:per_page],
          total:    data.count(:all)
        }
      }
    }
  end

  def paginate_params
    @paginate_params ||= {
      page:     (params[:page] || 1).to_i,
      per_page: [ (params[:per_page] || default_per_page).to_i, 100 ].min
    }
  end

  def default_per_page
    50
  end

  def rendering_options
    {
      include: serializer_options.fetch(:include) { [] },
      fields:  serializer_options.fetch(:fields) { {} },
      expose:  serializer_options.fetch(:expose) { {} },
      meta:    serializer_options.fetch(:meta) { {} },
      class:   serializer_options.fetch(:class, class_rendering_map)
    }.compact
  end

  def class_rendering_map
  end

  def serializer_options
    {}
  end

  def render_empty_response(status: :ok)
    render(json: { data: {}, status:, jsonapi: { version: "1.0" } }, status:)
  end
end
