module Api
  module V1
    class CommentsController < ApplicationController
      def index
        render_serialized Comment.where(post:)
      end

      def create
        render_serialized Comment.create!(create_params.merge(post:)), status: :created
      end

      private

      def post
        @post ||= Post.find(params[:post_id])
      end

      def create_params
        params.expect(resource: %i[content])
      end
    end
  end
end
