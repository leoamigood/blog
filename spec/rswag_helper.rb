# frozen_string_literal: true

module RswagHelper
  module RefHelper
    def draw_openapi_ref(*keys)
      "#/components/schemas/#{component_name(keys)}"
    end

    private

    def component_name(arr)
      arr.map { |name| name.to_s.camelize }.join('_')
    end
  end

  def self.parse_components(paths)
    result = paths.map { |path| Rails.root.glob("#{path}/**/*.yaml") }.flatten.map do |filepath|
      component = RswagComponentFile.new(filepath.to_s)

      [ component.name, component.to_yml ]
    end

    result.to_h.compact.presence
  end

  class RswagComponentFile
    include RefHelper

    SPLIT_BORDER_FOLDER = 'components'
    attr_reader :filepath, :filepath_splitted

    def initialize(filepath)
      @filepath = filepath
      @filepath_splitted = filepath.chomp('.yaml').split('/')
    end

    def name
      split_border_idx = filepath_splitted.index { |x| x == SPLIT_BORDER_FOLDER }
      component_name(
        filepath_splitted[(split_border_idx + 1)..]
      )
    end

    def to_yml
      YAML.safe_load(render, permitted_classes: [ Symbol ])
    end

    private

    def render
      ERB.new(File.read(filepath, encoding: 'utf-8')).result(binding)
    end
  end
end
