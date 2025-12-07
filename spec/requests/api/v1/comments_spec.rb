require 'swagger_helper'

describe 'Blog API', type: :request do
  let!(:entry) { Post.create(title: 'Post Title', content: 'Post Content', published: true) }

  path '/api/v1/posts/{post_id}/comments' do
    get 'List comments' do
      tags 'Comments'
      produces 'application/json'
      parameter name: :post_id, in: :path, type: :string
      parameter name: :page, in: :query, schema: { type: :string, required: false, description: 'Starts from 1' }
      parameter name: :per_page, in: :query, schema: { type: :string, required: false }

      let(:page) { 1 }
      let(:per_page) { 20 }

      let(:post_id) { entry.id }

      response '200', 'successful' do
        schema '$ref' => draw_openapi_ref(:requests, :comments, :index)
        run_test!
      end
    end

    post 'Creates a comment' do
      tags 'Comments'

      parameter name: :post_id, in: :path, type: :string
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            required: %w[type attributes meta],
            properties: {
              type: { type: :string, example: 'comments' },
              attributes: {
                type: :object,
                required: %w[content],
                properties: {
                  content: { type: :string, example: 'Comment Content' }
                }
              }
            }
          }
        }
      }, required: true

      let(:post_id) { entry.id }
      let(:data) do
        {
          data: {
            type: 'comments',
            attributes: {
              content: 'Comment Content'
            }
          }
        }
      end

      response '201', 'Comment created' do
        schema '$ref' => draw_openapi_ref(:requests, :comments, :create)

        run_test!
      end

      response '404', 'Post not found' do
        schema '$ref' => draw_openapi_ref(:shared, :BasicError)

        let(:post_id) { 'invalid' }
        run_test!
      end
    end
  end
end
