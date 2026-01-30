class CartsController < ApplicationController
  def create
    product = Product.find(cart_params[:product_id])
    quantity = cart_params[:quantity].to_i

    return render_invalid_quantity if quantity <= 0

    cart = current_cart
    item = find_or_build_item(cart, product)
    item.quantity = item.quantity.to_i + quantity
    item.save!

    cart.update_total_price!

    render json: cart_payload(cart), status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end

  private

  def render_invalid_quantity
    render json: { error: 'Quantity must be greater than 0' }, status: :unprocessable_entity
  end

  def find_or_build_item(cart, product)
    cart.cart_items.find_or_initialize_by(product: product)
  end

  def current_cart
    return create_cart unless session[:cart_id]

    Cart.find_by(id: session[:cart_id]) || create_cart
  end

  def create_cart
    cart = Cart.create!(total_price: 0)
    session[:cart_id] = cart.id
    cart
  end

  def cart_payload(cart)
    {
      id: cart.id,
      products: cart.cart_items.includes(:product).map { |item| cart_item_payload(item) },
      total_price: cart.total_price.to_f
    }
  end

  def cart_item_payload(item)
    {
      id: item.product.id,
      name: item.product.name,
      unit_price: item.unit_price.to_f,
      quantity: item.quantity,
      total_price: item.total_price.to_f
    }
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end
end