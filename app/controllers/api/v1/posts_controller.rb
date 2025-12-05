module Api
  module V1
    class PostsController < ApplicationController
      def index
        render_serialized Post.all
      end

      def create
        render_serialized Post.create!(create_params), status: :created
      end

      def show
        render_serialized Post.find(params[:id])
      end

      private

      def create_params
        params.expect(resource: %i[title content])
      end
    end
  end
end
