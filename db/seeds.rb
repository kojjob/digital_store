# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Helper method to create a random date within a range
def random_date(from, to)
  from + rand(to.to_i - from.to_i)
end

# Helper method to create a random price
def random_price(min, max, discount_probability = 0.7)
  price = (rand * (max - min) + min).round(2)
  has_discount = rand > discount_probability
  discount = has_discount ? (price * (rand * 0.4 + 0.1)).round(2) : nil
  [ price, discount ]
end

# Create users with different roles
puts "Creating users..."

# Admin user
admin = User.find_or_create_by(email: 'admin@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Admin'
  u.last_name = 'User'
  u.admin = true
end

# Regular user
user = User.find_or_create_by(email: 'test@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Test'
  u.last_name = 'User'
end

# Additional users
buyer1 = User.find_or_create_by(email: 'buyer1@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'John'
  u.last_name = 'Doe'
end

buyer2 = User.find_or_create_by(email: 'buyer2@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Jane'
  u.last_name = 'Smith'
end

# Create categories with subcategories
puts "Creating categories and subcategories..."

# Main categories with descriptions
categories = {
  'Digital Art' => 'Digital illustrations, paintings, and designs ready for use in your projects',
  'E-books' => 'Educational and informative digital books on various topics',
  'Web Templates' => 'Ready-to-use website templates and UI kits',
  'Stock Photos' => 'High quality royalty-free photography for commercial use',
  'Software' => 'Applications and software tools for productivity',
  'Audio Files' => 'Music, sound effects, and audio samples',
  'Video Resources' => 'Stock footage, animations, and video templates'
}

# Subcategories organized by parent category
subcategories = {
  'Digital Art' => [
    { name: 'Icons', description: 'Icon sets and individual icons for various purposes' },
    { name: 'UI Elements', description: 'User interface components and design elements' },
    { name: 'Illustrations', description: 'Digital illustrations and artwork' }
  ],
  'E-books' => [
    { name: 'Programming', description: 'Coding and software development guides' },
    { name: 'Business', description: 'Business strategy and management resources' },
    { name: 'Marketing', description: 'Digital marketing and advertising guides' }
  ],
  'Web Templates' => [
    { name: 'E-commerce', description: 'Online store templates and themes' },
    { name: 'Portfolio', description: 'Personal and professional portfolio templates' },
    { name: 'Landing Pages', description: 'Conversion-focused landing page templates' }
  ],
  'Stock Photos' => [
    { name: 'Nature', description: 'Landscapes, wildlife, and natural scenery' },
    { name: 'Business', description: 'Office, corporate, and professional settings' },
    { name: 'People', description: 'Portraits, lifestyle, and human interaction' }
  ],
  'Software' => [
    { name: 'Productivity', description: 'Tools for improving efficiency and workflow' },
    { name: 'Design', description: 'Graphic design and creative software' },
    { name: 'Development', description: 'Programming and development tools' }
  ],
  'Audio Files' => [
    { name: 'Music', description: 'Royalty-free music tracks and compositions' },
    { name: 'Sound Effects', description: 'Audio effects for multimedia projects' },
    { name: 'Voice Overs', description: 'Professional voice recordings and narrations' }
  ],
  'Video Resources' => [
    { name: 'Stock Footage', description: 'Royalty-free video clips and b-roll' },
    { name: 'Motion Graphics', description: 'Animated elements and transitions' },
    { name: 'Video Templates', description: 'Editable video project templates' }
  ]
}

created_categories = {}

# Create main categories
categories.each_with_index do |(name, description), index|
  created_categories[name] = Category.find_or_create_by(name: name) do |c|
    c.description = description
    c.visible = true
    c.position = index + 1
    c.icon_name = "category-#{name.parameterize}"
    c.icon_color = [ 'blue', 'green', 'red', 'purple', 'orange', 'teal', 'pink' ].sample
  end
end

# Create subcategories
subcategories.each do |parent_name, sub_cats|
  parent = created_categories[parent_name]

  sub_cats.each_with_index do |sub_cat, index|
    Category.find_or_create_by(name: sub_cat[:name], parent: parent) do |c|
      c.description = sub_cat[:description]
      c.visible = true
      c.position = index + 1
      c.slug = "#{parent_name.parameterize}-#{sub_cat[:name].parameterize}"
      c.icon_name = "subcategory-#{sub_cat[:name].parameterize}"
      c.icon_color = parent.icon_color
    end
  end
end

# Create sellers with different profiles
puts "Creating sellers..."

# Create a seller for the regular test user
seller = Seller.find_or_create_by(user: user) do |s|
  s.business_name = 'Digital Creations'
  s.description = 'High-quality digital products for creative professionals'
  s.location = 'Accra'
  s.country = 'Ghana'
  s.phone_number = '+233000000000'
  s.verified = true
  s.commission_rate = 5.0
  s.acceptance_rate = 98.5
  s.average_response_time = 2 # hours
end

# Create a seller for buyer1 (making them both a buyer and seller)
seller2 = Seller.find_or_create_by(user: buyer1) do |s|
  s.business_name = 'Nigerian Creatives'
  s.description = 'Digital products created by talented Nigerian artists'
  s.location = 'Lagos'
  s.country = 'Nigeria'
  s.phone_number = '+2340000000000'
  s.verified = true
  s.commission_rate = 5.0
  s.acceptance_rate = 95.0
  s.average_response_time = 4 # hours
end

# Create a new seller for buyer2
seller3 = Seller.find_or_create_by(user: buyer2) do |s|
  s.business_name = 'Design Masters'
  s.description = 'Premium design resources for professionals'
  s.location = 'Cape Town'
  s.country = 'South Africa'
  s.phone_number = '+27000000000'
  s.verified = true
  s.commission_rate = 6.5
  s.acceptance_rate = 92.0
  s.average_response_time = 6 # hours
end

# Create an unverified seller for testing verification flows
unverified_seller = User.find_or_create_by(email: 'unverified@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Pending'
  u.last_name = 'Verification'
end

seller4 = Seller.find_or_create_by(user: unverified_seller) do |s|
  s.business_name = 'New Digital Shop'
  s.description = 'Fresh digital products from emerging creators'
  s.location = 'Nairobi'
  s.country = 'Kenya'
  s.phone_number = '+254000000000'
  s.verified = false
  s.commission_rate = 7.0
  s.acceptance_rate = 85.0
  s.average_response_time = 12 # hours
end

# Create products with more detailed information
puts "Creating products..."

# Get all subcategories for reference
all_subcategories = Category.where.not(parent_id: nil).to_a

# Helper method to find a subcategory by name within a parent category
def find_subcategory(subcategories, parent_name, subcategory_name)
  parent_category = Category.find_by(name: parent_name, parent_id: nil)
  return nil unless parent_category

  subcategories.find { |sc| sc.name == subcategory_name && sc.parent_id == parent_category.id }
end

# Create test products with more detailed information
products_data = [
  {
    name: 'Premium Icon Pack',
    description: 'A collection of 500+ high-quality icons in multiple formats (SVG, PNG, AI) suitable for web and mobile applications. Includes various categories like UI elements, social media, business, and more.',
    price: 29.99,
    discounted_price: 24.99,
    stock_quantity: 999,
    sku: 'ICON-PACK-001',
    category_name: 'Digital Art',
    subcategory_name: 'Icons',
    seller: seller,
    currency: 'GHS',
    featured: true,
    condition: 'New',
    brand: 'DigitalCreations',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Ghana',
    available_in_ghana: true,
    available_in_nigeria: true,
    meta_title: 'Premium Icon Pack - 500+ High Quality Icons',
    meta_description: 'Download our premium icon pack with over 500 high-quality icons in multiple formats for your web and mobile applications.'
  },
  {
    name: 'Web Development Guide 2023',
    description: 'Comprehensive e-book covering modern web development practices, frameworks, and tools. Learn how to build responsive, accessible, and high-performance websites using the latest technologies.',
    price: 19.99,
    stock_quantity: 999,
    sku: 'EBOOK-WEB-001',
    category_name: 'E-books',
    subcategory_name: 'Programming',
    seller: seller,
    currency: 'GHS',
    condition: 'New',
    brand: 'DigitalCreations',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Ghana',
    available_in_ghana: true,
    meta_title: 'Web Development Guide 2023 - Modern Practices & Tools',
    meta_description: 'Learn modern web development with our comprehensive guide covering the latest frameworks, tools, and best practices.'
  },
  {
    name: 'E-commerce Website Template',
    description: 'Ready-to-use e-commerce website template with product listings, shopping cart, checkout process, and user authentication. Built with modern frameworks for optimal performance.',
    price: 59.99,
    discounted_price: 49.99,
    stock_quantity: 50,
    sku: 'TEMPLATE-ECOM-001',
    category_name: 'Web Templates',
    subcategory_name: 'E-commerce',
    seller: seller,
    currency: 'GHS',
    featured: true,
    condition: 'New',
    brand: 'DigitalCreations',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Ghana',
    available_in_ghana: true,
    available_in_nigeria: true,
    meta_title: 'Complete E-commerce Website Template - Ready to Use',
    meta_description: 'Launch your online store quickly with our ready-to-use e-commerce website template featuring product listings, shopping cart, and more.'
  },
  {
    name: 'African Landscapes Photo Bundle',
    description: 'A collection of 100 high-resolution photos showcasing the beautiful and diverse landscapes across Africa. Perfect for websites, presentations, and marketing materials.',
    price: 39.99,
    stock_quantity: 100,
    sku: 'PHOTOS-AFRICA-001',
    category_name: 'Stock Photos',
    subcategory_name: 'Nature',
    seller: seller2,
    currency: 'NGN',
    condition: 'New',
    brand: 'Nigerian Creatives',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Nigeria',
    available_in_nigeria: true,
    meta_title: 'African Landscapes Photo Bundle - 100 High-Res Images',
    meta_description: 'Showcase the beauty of Africa with our collection of 100 high-resolution landscape photos perfect for your creative projects.'
  },
  {
    name: 'Productivity Toolkit Software',
    description: 'Comprehensive suite of productivity tools including task management, time tracking, note-taking, and project planning features. Available for Windows, Mac, and Linux.',
    price: 79.99,
    discounted_price: 59.99,
    stock_quantity: 200,
    sku: 'SOFTWARE-PROD-001',
    category_name: 'Software',
    subcategory_name: 'Productivity',
    seller: seller,
    currency: 'GHS',
    condition: 'New',
    brand: 'DigitalCreations',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Ghana',
    available_in_ghana: true,
    meta_title: 'Productivity Toolkit Software - Boost Your Efficiency',
    meta_description: 'Increase your productivity with our comprehensive toolkit featuring task management, time tracking, and project planning tools.'
  },
  {
    name: 'African Drums Sample Pack',
    description: 'Authentic recordings of traditional African percussion instruments. Includes 200+ high-quality WAV files perfect for music production, film scoring, and sound design.',
    price: 34.99,
    stock_quantity: 150,
    sku: 'AUDIO-DRUMS-001',
    category_name: 'Audio Files',
    subcategory_name: 'Sound Effects',
    seller: seller2,
    currency: 'NGN',
    featured: true,
    condition: 'New',
    brand: 'Nigerian Creatives',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Nigeria',
    available_in_nigeria: true,
    meta_title: 'African Drums Sample Pack - 200+ Authentic Recordings',
    meta_description: 'Add authentic African percussion to your music with our collection of 200+ high-quality drum samples and sound effects.'
  },
  {
    name: 'City Timelapse Video Collection',
    description: 'Stunning 4K timelapse footage of major African cities including Accra, Lagos, Nairobi, and Cape Town. Royalty-free for commercial use in your video projects.',
    price: 49.99,
    stock_quantity: 75,
    sku: 'VIDEO-CITY-001',
    category_name: 'Video Resources',
    subcategory_name: 'Stock Footage',
    seller: seller,
    currency: 'GHS',
    condition: 'New',
    brand: 'DigitalCreations',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Ghana',
    available_in_ghana: true,
    available_in_nigeria: true,
    meta_title: 'African Cities 4K Timelapse Collection - Royalty Free',
    meta_description: 'Enhance your video projects with stunning 4K timelapse footage of major African cities, royalty-free for commercial use.'
  },
  {
    name: 'Digital Marketing Strategy Guide',
    description: 'Comprehensive e-book on building effective digital marketing strategies for African markets. Includes case studies, templates, and actionable advice.',
    price: 24.99,
    stock_quantity: 999,
    sku: 'EBOOK-MKTG-001',
    category_name: 'E-books',
    subcategory_name: 'Marketing',
    seller: seller,
    currency: 'GHS',
    condition: 'New',
    brand: 'DigitalCreations',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Ghana',
    available_in_ghana: true,
    meta_title: 'Digital Marketing Strategy Guide for African Markets',
    meta_description: 'Develop effective digital marketing strategies for African markets with our comprehensive guide featuring case studies and templates.'
  },
  {
    name: 'UI Elements Library',
    description: 'Extensive library of UI components including buttons, forms, cards, navigation elements, and more. Available in Figma, Sketch, and Adobe XD formats.',
    price: 44.99,
    discounted_price: 39.99,
    stock_quantity: 500,
    sku: 'DIGITAL-UI-001',
    category_name: 'Digital Art',
    subcategory_name: 'UI Elements',
    seller: seller2,
    currency: 'NGN',
    condition: 'New',
    brand: 'Nigerian Creatives',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Nigeria',
    available_in_nigeria: true,
    meta_title: 'UI Elements Library - Complete Design Components',
    meta_description: 'Access our extensive library of UI components including buttons, forms, cards, and navigation elements for your design projects.'
  },
  {
    name: 'Portfolio Website Template',
    description: 'Clean and modern portfolio template designed for creatives. Features project showcase, about section, contact form, and blog. Easy to customize with minimal coding required.',
    price: 29.99,
    stock_quantity: 200,
    sku: 'TEMPLATE-PORT-001',
    category_name: 'Web Templates',
    subcategory_name: 'Portfolio',
    seller: seller,
    currency: 'GHS',
    condition: 'New',
    brand: 'DigitalCreations',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'Ghana',
    available_in_ghana: true,
    meta_title: 'Modern Portfolio Website Template for Creatives',
    meta_description: 'Showcase your creative work with our clean, modern portfolio template featuring project galleries, about section, and contact form.'
  },
  # Additional products for seller3
  {
    name: 'Professional Resume Templates',
    description: 'Collection of 10 professionally designed resume templates in Word and InDesign formats. Includes matching cover letter templates and detailed customization instructions.',
    price: 19.99,
    discounted_price: 14.99,
    stock_quantity: 300,
    sku: 'TEMPLATE-RESUME-001',
    category_name: 'Digital Art',
    subcategory_name: 'UI Elements',
    seller: seller3,
    currency: 'ZAR',
    condition: 'New',
    brand: 'Design Masters',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'South Africa',
    meta_title: 'Professional Resume Templates - Stand Out to Employers',
    meta_description: 'Land your dream job with our professionally designed resume templates, complete with matching cover letters and customization guides.'
  },
  {
    name: 'Social Media Marketing Course',
    description: 'Comprehensive video course on social media marketing strategies for African businesses. Includes 20+ video lessons, worksheets, and case studies.',
    price: 89.99,
    discounted_price: 69.99,
    stock_quantity: 100,
    sku: 'COURSE-SM-001',
    category_name: 'Video Resources',
    subcategory_name: 'Video Templates',
    seller: seller3,
    currency: 'ZAR',
    featured: true,
    condition: 'New',
    brand: 'Design Masters',
    weight: 0.0,
    dimensions: 'Digital',
    shipping_time: 'Instant',
    country_of_origin: 'South Africa',
    meta_title: 'Social Media Marketing Course for African Businesses',
    meta_description: 'Master social media marketing with our comprehensive course designed specifically for businesses operating in African markets.'
  }
]

created_products = []

# Helper method to generate realistic review content
def generate_review_content(rating)
  case rating
  when 5
    [
      "Absolutely love this product! Exceeded all my expectations and worth every penny.",
      "Outstanding quality and value. I've recommended it to all my colleagues.",
      "This is exactly what I was looking for. Perfect in every way!",
      "Incredible product that has transformed my workflow. Can't imagine working without it now.",
      "Five stars isn't enough! This product is exceptional in every aspect."
    ].sample
  when 4
    [
      "Very good product with minor room for improvement. Would definitely recommend.",
      "Really happy with my purchase. Just a few small things could be better.",
      "Great value for money and does everything as advertised.",
      "Solid product that meets all my needs. Just missing a few nice-to-have features.",
      "High quality and well designed. Just a few small issues prevent a perfect score."
    ].sample
  when 3
    [
      "Decent product that does the job, but nothing special.",
      "Average quality for the price. Works as expected but doesn't wow me.",
      "It's okay. Does what it claims but has some limitations.",
      "Middle-of-the-road product. Some good features, some that need improvement.",
      "Satisfactory but not outstanding. Gets the job done."
    ].sample
  when 2
    [
      "Disappointed with several aspects of this product. Wouldn't recommend.",
      "Below average quality. Several issues that make it frustrating to use.",
      "Not worth the price. Too many problems and limitations.",
      "Expected much better. Several features don't work as advertised.",
      "Underwhelming product with multiple issues that need addressing."
    ].sample
  when 1
    [
      "Very disappointed. Would not recommend to anyone.",
      "Waste of money. Doesn't work as described at all.",
      "Terrible quality and customer service. Stay away!",
      "Completely unsatisfied with this purchase. Many issues and problems.",
      "One of the worst products I've ever bought. Avoid at all costs."
    ].sample
  end
end

products_data.each do |product_data|
  # Find the main category
  category = created_categories[product_data[:category_name]]

  # Try to find the subcategory if specified
  if product_data[:subcategory_name].present?
    subcategory = find_subcategory(all_subcategories, product_data[:category_name], product_data[:subcategory_name])
    category = subcategory if subcategory.present?
  end

  # Create or update the product
  product = Product.find_or_create_by(sku: product_data[:sku]) do |p|
    p.name = product_data[:name]
    p.description = product_data[:description]
    p.price = product_data[:price]
    p.discounted_price = product_data[:discounted_price]
    p.stock_quantity = product_data[:stock_quantity]
    p.currency = product_data[:currency]
    p.category = category
    p.seller = product_data[:seller]
    p.published = true
    p.published_at = random_date(1.year.ago, 1.day.ago)
    p.available_in_ghana = product_data[:available_in_ghana] || false
    p.available_in_nigeria = product_data[:available_in_nigeria] || false
    p.featured = product_data[:featured] || false
    p.condition = product_data[:condition]
    p.brand = product_data[:brand]
    p.weight = product_data[:weight]
    p.dimensions = product_data[:dimensions]
    p.shipping_time = product_data[:shipping_time]
    p.country_of_origin = product_data[:country_of_origin]
    p.meta_title = product_data[:meta_title]
    p.meta_description = product_data[:meta_description]
  end

  created_products << product
end

# Create reviews for products
puts "Creating product reviews..."

# Users who will leave reviews
reviewers = [ user, buyer1, buyer2, admin ]

created_products.each do |product|
  # Generate between 0 and 8 reviews for each product
  review_count = rand(0..8)

  review_count.times do
    # Select a random user to leave the review
    reviewer = reviewers.sample

    # Skip if this user already reviewed this product
    next if Review.exists?(user: reviewer, product: product)

    # Generate a random rating (weighted towards higher ratings)
    rating_weights = [ 1, 2, 3, 4, 5, 5, 5, 4, 4 ]
    rating = rating_weights.sample

    # Create the review
    Review.create!(
      user: reviewer,
      product: product,
      rating: rating,
      content: generate_review_content(rating),
      created_at: random_date(product.published_at || 6.months.ago, 1.day.ago)
    )
  end
end

# Create orders for users
puts "Creating orders..."

# Order statuses with weights (more completed than others)
order_statuses = [
  { status: 'completed', weight: 10 },
  { status: 'pending', weight: 3 },
  { status: 'processing', weight: 2 },
  { status: 'cancelled', weight: 1 },
  { status: 'refunded', weight: 1 }
]

# Flatten the statuses based on weights
weighted_statuses = order_statuses.flat_map { |s| [ s[:status] ] * s[:weight] }

# Create orders for each user
[ user, buyer1, buyer2 ].each do |buyer|
  # Generate between 0 and 10 orders for each user
  order_count = rand(0..10)

  order_count.times do
    # Select a random product
    product = created_products.sample

    # Generate a random status (weighted)
    status = weighted_statuses.sample

    # Create the order
    Order.create!(
      user: buyer,
      product: product,
      status: status,
      total_amount: product.discounted_price || product.price,
      created_at: random_date(product.published_at || 6.months.ago, 1.day.ago)
    )
  end
end

# Create wishlist items
puts "Creating wishlist items..."

[ user, buyer1, buyer2 ].each do |buyer|
  # Generate between 0 and 5 wishlist items for each user
  wishlist_count = rand(0..5)

  # Get random products for wishlist (ensure no duplicates)
  wishlist_products = created_products.sample(wishlist_count)

  wishlist_products.each do |product|
    WishlistItem.create!(
      user: buyer,
      product: product,
      notes: [ nil, "Interested in this", "For future project", "Gift idea" ].sample,
      created_at: random_date(product.published_at || 6.months.ago, 1.day.ago)
    )
  end
end

# Create user activities
puts "Creating user activities..."

# Activity types with their properties
activity_types = [
  { type: 'login', title: 'Logged In', icon: 'login', color: 'blue' },
  { type: 'purchase', title: 'Made a Purchase', icon: 'shopping_cart', color: 'green' },
  { type: 'review', title: 'Left a Review', icon: 'star', color: 'yellow' },
  { type: 'wishlist', title: 'Added to Wishlist', icon: 'favorite', color: 'red' },
  { type: 'profile_update', title: 'Updated Profile', icon: 'person', color: 'purple' }
]

[ user, buyer1, buyer2 ].each do |user_record|
  # Generate between 5 and 15 activities for each user
  activity_count = rand(5..15)

  activity_count.times do
    # Select a random activity type
    activity = activity_types.sample

    # Create the activity
    UserActivity.create!(
      user: user_record,
      activity_type: activity[:type],
      title: activity[:title],
      description: "User performed #{activity[:title].downcase} action",
      icon: activity[:icon],
      color: activity[:color],
      created_at: random_date(6.months.ago, 1.hour.ago)
    )
  end
end

# Create notifications
puts "Creating notifications..."

# Notification types and messages
notification_types = [
  { type: 0, title: 'New Product Available', message: 'A new product you might be interested in is now available.' },
  { type: 0, title: 'Price Drop Alert', message: 'A product in your wishlist has dropped in price!' },
  { type: 1, title: 'Order Confirmation', message: 'Your order has been confirmed and is being processed.' },
  { type: 1, title: 'Order Shipped', message: 'Your order has been shipped and is on its way.' },
  { type: 2, title: 'Account Security', message: 'Your password was changed recently. If this wasn\'t you, please contact support.' },
  { type: 2, title: 'Welcome to Digital Store', message: 'Thank you for joining our platform. Start exploring digital products now!' }
]

[ user, buyer1, buyer2 ].each do |user_record|
  # Generate between 3 and 8 notifications for each user
  notification_count = rand(3..8)

  notification_count.times do
    # Select a random notification type
    notification = notification_types.sample

    # Randomly decide if notification has been read
    read_at = rand > 0.3 ? random_date(1.month.ago, 1.hour.ago) : nil

    # Create the notification
    Notification.create!(
      user: user_record,
      title: notification[:title],
      message: notification[:message],
      notification_type: notification[:type],
      status: read_at.present? ? 1 : 0,  # 0 for unread, 1 for read
      read_at: read_at,
      created_at: random_date(3.months.ago, 1.day.ago)
    )
  end
end

# Create carts for users
puts "Creating carts..."

[ user, buyer1, buyer2 ].each do |user_record|
  # Create a cart for each user
  cart = Cart.find_or_create_by(user: user_record)

  # Add 0-3 items to cart
  cart_item_count = rand(0..3)

  cart_item_products = created_products.sample(cart_item_count)

  cart_item_products.each do |product|
    # Add product to cart with random quantity (1-3)
    cart.add_product(product.id, rand(1..3))
  end
end

puts "Seed data creation completed successfully!"

puts "Seed data created successfully!"
puts "Created user: #{user.email}"
puts "Created categories: #{created_categories.keys.join(', ')}"
puts "Created sellers: #{seller.business_name}, #{seller2.business_name}"
puts "Created #{created_products.count} products"
