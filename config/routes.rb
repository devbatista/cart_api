Rails.application.routes.draw do
  resource :cart, only: [:create, :show, :destroy] do
    patch :add_item, on: :collection
    delete ':product_id', to: 'carts#destroy', as: :remove_item
  end
end