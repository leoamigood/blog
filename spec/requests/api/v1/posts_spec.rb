require 'swagger_helper'

describe 'Blog API', type: :request do
  path '/api/v1/posts' do
    get 'List posts' do
      tags 'Posts'
      consumes 'application/json'
      parameter name: :page, in: :query, schema: { type: :string, required: false, description: 'Starts from 1' }
      parameter name: :per_page, in: :query, schema: { type: :string, required: false }

      let(:page) { 1 }
      let(:per_page) { 20 }

      response '200', 'successful' do
        schema '$ref' => draw_openapi_ref(:requests, :posts, :index)
        run_test!
      end
    end

    post 'Creates a post' do
      tags 'Posts'

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            required: %w[type attributes meta],
            properties: {
              type: { type: :string, example: 'posts' },
              attributes: {
                type: :object,
                required: %w[title content],
                properties: {
                  title: { type: :string, example: 'Post Title' },
                  content: { type: :string, example: 'Post Content' },
                  published: { type: :boolean, example: true }
                }
              }
            }
          }
        }
      }, required: true

      let(:data) do
        {
          data: {
            type: 'posts',
            attributes: {
              title: 'Post Title',
              content: 'Post Content'
            }
          }
        }
      end

      response '201', 'Post created' do
        schema '$ref' => draw_openapi_ref(:requests, :posts, :create)

        run_test!
      end

      response '422', 'Content Required' do
        let(:data) do
          {
            data: {
              type: 'posts',
              attributes: {
                title: 'Title Only'
              }
            }
          }
        end
        schema '$ref' => draw_openapi_ref(:shared, :BasicError)

        run_test!
      end
    end
  end

  path '/api/v1/posts/{id}' do
    get 'Retrieves a post with comments' do
      tags 'Posts'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :string

      let(:post) { Post.create(title: 'Post Title', content: 'Post Content', published: true) }

      response '200', 'post found' do
        schema '$ref' => draw_openapi_ref(:requests, :posts, :show)

        let(:id) { post.id }
        run_test!
      end

      response '404', 'post not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
