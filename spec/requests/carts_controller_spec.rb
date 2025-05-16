require 'rails_helper'

RSpec.describe "Carts API", type: :request do
  let!(:product) { create(:product) }
  let!(:cart) { create(:cart) }
  let(:headers) { { "X-Cart-Id" => cart.id.to_s } }

  describe "POST /cart" do
    it "adiciona um produto ao carrinho" do
      post '/cart', params: { product_id: product.id, quantity: 2 }, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['products'].first['id']).to eq(product.id)
      expect(json['products'].first['quantity']).to eq(2)
    end

    it "retorna erro para quantidade inválida" do
      post '/cart', params: { product_id: product.id, quantity: 0 }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "retorna erro para produto inexistente" do
      post '/cart', params: { product_id: 999_999, quantity: 1 }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /cart" do
    before do
      create(:cart_item, cart: cart, product: product, quantity: 3, unit_price: product.unit_price)
    end

    it "retorna os itens do carrinho" do
      get '/cart', headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['products'].size).to eq(1)
      expect(json['products'].first['quantity']).to eq(3)
    end
  end

  describe "PATCH /cart/add_item" do
    before do
      create(:cart_item, cart: cart, product: product, quantity: 1, unit_price: product.unit_price)
    end

    it "atualiza a quantidade do item" do
      patch '/cart/add_item', params: { product_id: product.id, quantity: 5 }, headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['products'].first['quantity']).to eq(5)
    end

    it "retorna erro se produto não está no carrinho" do
      patch '/cart/add_item', params: { product_id: 999_999, quantity: 1 }, headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it "retorna erro para quantidade inválida" do
      patch '/cart/add_item', params: { product_id: product.id, quantity: 0 }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /cart/:product_id" do
    let(:product) { create(:product) }
    let(:cart) { create(:cart) }
    let(:headers) { { "X-Cart-Id" => cart.id.to_s } }

    before do
      @item = create(:cart_item, cart: cart, product: product, quantity: 1, unit_price: product.unit_price)
      puts "Created CartItem -> cart_id: #{cart.id}, product_id: #{product.id}"
    end

    it "remove o item do carrinho" do
      delete "/cart/#{product.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['products']).to be_empty
    end

    it "retorna erro se produto não está no carrinho" do
      delete "/cart/999999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
