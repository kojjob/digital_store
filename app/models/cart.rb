class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def add_product(product_id, quantity = 1)
    # Find the product first to validate it exists
    product = Product.find_by(id: product_id)
    return false unless product

    # Find or create a cart item
    current_item = cart_items.find_by(product_id: product_id)

    if current_item
      # Update quantity if already in cart
      current_item.quantity += quantity.to_i
      current_item.save
    else
      # Create new cart item if not already in cart
      current_item = cart_items.create(
        product_id: product_id,
        quantity: quantity,
        price: product.effective_price # Using effective_price instead of actual_price
      )
    end

    current_item
  end

  def remove_product(product_id)
    item = cart_items.find_by(product_id: product_id)
    item&.destroy
  end

  def update_quantity(product_id, quantity)
    item = cart_items.find_by(product_id: product_id)

    if item && quantity.to_i > 0
      item.quantity = quantity.to_i
      item.save
    elsif item
      # Remove item if quantity is zero or negative
      item.destroy
    end
  end

  def total
    cart_items.sum { |item| item.price * item.quantity }
  end

  def empty?
    cart_items.empty?
  end

  def clear
    cart_items.destroy_all
  end

  # Check if a product is in the cart
  def has_product?(product_id)
    cart_items.exists?(product_id: product_id)
  end
end
