require 'swagger_helper'

describe 'Blog API', type: :request do
  path '/posts.json' do
    post 'Creates a post' do
      tags 'Posts'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        },
        required: %w[title content]
      }

      response '201', 'post created' do
        let(:params) { { title: 'foo', content: 'bar' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:params) { { title: 'foo' } }
        run_test!
      end
    end
  end

  path '/posts/{id}' do
    get 'Retrieves a post' do
      tags 'Blog', 'Posts'
      produces 'application/json', 'application/xml'
      parameter name: 'id', in: :path, type: :string
      request_body_example value: { some_field: 'Foo' }, name: 'basic', summary: 'Request example description'

      let(:post) { Post.create(title: 'foo', content: 'bar') }

      response '200', 'post found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 content: { type: :string }
               },
               required: %w[id title content]

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
