require 'rails_helper'

RSpec.describe 'Carts', type: :request do
  let(:product) { Product.create!(name: 'Test Product', price: 10.0) }

  describe 'POST /cart' do
    it 'cria um carrinho na sessão e adiciona um produto' do
      post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)

      expect(body['id']).to be_present
      expect(body['products'].size).to eq(1)

      item = body['products'].first
      expect(item['id']).to eq(product.id)
      expect(item['name']).to eq(product.name)
      expect(item['quantity']).to eq(2)
      expect(item['unit_price']).to eq(10.0)
      expect(item['total_price']).to eq(20.0)

      expect(body['total_price']).to eq(20.0)
    end

    it 'retorna erro quando o produto não existe' do
      post '/cart', params: { product_id: 0, quantity: 1 }, as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Product not found')
    end

    it 'retorna erro quando a quantidade é inválida' do
      post '/cart', params: { product_id: product.id, quantity: 0 }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Quantity must be greater than 0')
    end
  end

  describe 'GET /cart' do
    it 'lista os itens do carrinho atual' do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

      get '/cart', as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['id']).to be_present
      expect(body['products'].size).to eq(1)
      expect(body['total_price']).to eq(10.0)
    end

    it 'retorna not_found quando não existe carrinho na sessão' do
      get '/cart', as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Cart not found')
    end
  end

  describe 'POST /cart/add_item' do
    it 'altera a quantidade de um produto que já está no carrinho' do
      post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json

      post '/cart/add_item', params: { product_id: product.id, quantity: 5 }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      item = body['products'].find { |p| p['id'] == product.id }
      expect(item['quantity']).to eq(5)
      expect(item['unit_price']).to eq(10.0)
      expect(item['total_price']).to eq(50.0)
      expect(body['total_price']).to eq(50.0)
    end

    it 'retorna erro quando a quantidade é inválida' do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

      post '/cart/add_item', params: { product_id: product.id, quantity: 0 }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Quantity must be greater than 0')
    end

    it 'retorna erro quando o produto não existe' do
      post '/cart/add_item', params: { product_id: 0, quantity: 1 }, as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Product not found')
    end
  end

  describe 'DELETE /cart/:product_id' do
    it 'remove o produto do carrinho e atualiza os totais' do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

      delete "/cart/#{product.id}", as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['products']).to eq([])
      expect(body['total_price']).to eq(0.0)
    end

    it 'retorna erro quando o produto não está no carrinho' do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json

      delete "/cart/999999", as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Item not found in cart')
    end

    it 'retorna erro quando não há carrinho na sessão' do
      delete "/cart/#{product.id}", as: :json

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Cart not found')
    end
  end
end