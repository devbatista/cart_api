# app/controllers/carts_controller.rb
class CartsController < ApplicationController
  before_action :set_cart

  # POST /cart
  def create
    product = Product.find_by(id: params[:product_id])
    return render json: { error: 'Produto não encontrado' }, status: :not_found unless product

    quantity = params[:quantity].to_i
    return render json: { error: 'Quantidade deve ser maior que zero' }, status: :unprocessable_entity if quantity <= 0

    item = @cart.cart_items.find_by(product_id: product.id)

    if item
      item.update!(quantity: item.quantity + quantity)
    else
      @cart.cart_items.create!(product: product, quantity: quantity, unit_price: product.unit_price)
    end

    @cart.touch_last_interaction!
    render json: cart_payload(@cart), status: :created
  end

  # GET /cart
  def show
    render json: cart_payload(@cart)
  end

  # PATCH /cart/add_item
  def add_item
    item = @cart.cart_items.find_by(product_id: params[:product_id])
    return render json: { error: 'Produto não está no carrinho' }, status: :not_found unless item

    quantity = params[:quantity].to_i
    return render json: { error: 'Quantidade deve ser maior que zero' }, status: :unprocessable_entity if quantity <= 0

    item.update!(quantity: quantity)
    @cart.touch_last_interaction!

    render json: cart_payload(@cart)
  end

  # DELETE /cart/:product_id
  def destroy
    item = @cart.cart_items.find_by(product_id: params[:product_id])
    return render json: { error: 'Produto não está no carrinho' }, status: :not_found unless item

    item.destroy!
    @cart.touch_last_interaction!

    render json: cart_payload(@cart)
  end

  private

  def set_cart
    # permite usar o header `X-Cart-Id` para facilitar testes e integração
    session_cart_id = (request.headers["X-Cart-Id"] || session[:cart_id])

    @cart = Cart.find_by(id: session_cart_id)

    unless @cart
      @cart = Cart.create!(last_interaction_at: Time.current)
      session[:cart_id] = @cart.id
    end
  end

  def cart_payload(cart)
    {
      id: cart.id,
      products: cart.cart_items.includes(:product).map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.unit_price.to_f,
          total_price: (item.unit_price * item.quantity).to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
