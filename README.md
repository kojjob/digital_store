# Digital Store

A modern e-commerce platform for digital products built with **Ruby on Rails 8**, **Hotwire**, **TailwindCSS**, **PostgreSQL**, and more. The platform supports seamless digital product delivery with integrated payment options: **direct mobile money (Momo) integration** for Ghana and Nigeria, alongside **Stripe** for card payments.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
  - [Momo Integration Setup](#momo-integration-setup)
  - [Stripe Integration Setup](#stripe-integration-setup)
- [Usage](#usage)
- [Models & Associations](#models--associations)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Overview

Digital Store is designed to provide a frictionless experience for users looking to purchase and instantly download digital products. The application integrates direct mobile money APIs from key providers (MTN, Airtel, Vodafone) for Ghana and Nigeria, ensuring that users can transact without needing a debit/credit card.

## Features

- **User Authentication:** Secure sign-up/login with Devise.
- **Product Catalog:** Browse digital products with details like name, description, price, and download link.
- **Shopping Cart:** Add products, update quantities, and checkout with ease.
- **Payment Integration:**
  - **Direct Momo Integration:** Supports direct mobile money payments in Ghana and Nigeria.
  - **Stripe Integration:** For users preferring card-based transactions.
- **Digital Delivery:** Secure, expiring download links post-purchase.
- **Real-Time Updates:** Utilizes Hotwire (Turbo Streams & StimulusJS) for dynamic user interactions.
- **Responsive Design:** Styled with TailwindCSS for a modern, responsive UI.

## Tech Stack

- **Backend:** Ruby on Rails 8
- **Frontend:** Hotwire (Turbo, StimulusJS), TailwindCSS, HTML, ERB
- **Database:** PostgreSQL
- **Payments:** Direct Momo API integration (MTN, Airtel, Vodafone) and Stripe
- **Deployment:** Options include Fly.io, Render, or DigitalOcean

## Installation

### Prerequisites

- Ruby (version 3.0 or higher)
- Rails 8
- PostgreSQL
- Node.js & Yarn (for managing JavaScript packages)
- Git

### Setup

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/yourusername/digital_store.git
   cd digital_store
   ```

2. **Install Dependencies:**
   ```sh
   bundle install
   yarn install
   ```

3. **Setup Database:**
   ```sh
   rails db:create
   rails db:migrate
   rails db:seed  # Optional: Seeds initial data for testing.
   ```

4. **Run the Server:**
   ```sh
   rails server
   ```
   Open your browser and navigate to [http://localhost:3000](http://localhost:3000) to see the application running.

## Configuration

### Environment Variables

Create a `.env` file (or use your preferred method) to store sensitive configuration details:

```dotenv
# Momo API Credentials
MOMO_MTN_API_KEY=your_mtn_api_key
MOMO_AIRTEL_API_KEY=your_airtel_api_key
MOMO_VODAFONE_API_KEY=your_vodafone_api_key

# Stripe API Keys
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
STRIPE_SECRET_KEY=your_stripe_secret_key

# Other configuration variables
SECRET_KEY_BASE=your_secret_key_base
```

Make sure to load these variables in your Rails application (consider using [dotenv-rails](https://github.com/bkeepers/dotenv)).

### Momo Integration Setup

1. **Register with Telcos:**  
   Obtain API credentials by registering your business with MTN, Airtel, and Vodafone in Ghana and Nigeria.
   
2. **Implement API Requests:**  
   Develop service objects in Rails that:
   - Initiate a Momo payment request with the user's phone number.
   - Handle USSD/push confirmation.
   - Verify and update order status using webhooks or polling.

3. **Error Handling:**  
   Ensure robust error handling for failed or pending transactions.

### Stripe Integration Setup

1. **Stripe Gem:**  
   Install and configure the [Stripe gem](https://github.com/stripe/stripe-ruby).
   
2. **Payment Flow:**  
   Implement Stripe Checkout sessions and handle webhook events to update order statuses after successful card payments.

## Usage

- **User Registration & Login:**  
  Users can sign up and log in using the Devise authentication system.
- **Browse & Purchase:**  
  Browse the product catalog, add products to the shopping cart, and proceed to checkout.
- **Payment:**  
  Choose between mobile money (Momo) or Stripe for payment.
- **Digital Delivery:**  
  Once payment is confirmed, users receive secure download links for their purchased products.

## Models & Associations

- **User:**  
  - Attributes: Email, Password, etc. (managed by Devise)  
  - Associations: `has_many :orders`, `has_one :cart`
  
- **Product:**  
  - Attributes: Name, Description, Price, File URL  
  - Associations: `has_many :line_items`
  
- **Cart:**  
  - Attributes: User ID  
  - Associations: `belongs_to :user`, `has_many :line_items`
  
- **LineItem:**  
  - Attributes: Product ID, Cart ID, Quantity  
  - Associations: `belongs_to :cart`, `belongs_to :product`
  
- **Order:**  
  - Attributes: User ID, Status, Total Price, Momo Transaction ID, Stripe Charge ID  
  - Associations: `belongs_to :user`

## Deployment

### Recommended Deployment Options

- **Fly.io:**
  ```sh
  fly launch
  fly deploy
  ```
- **Render/DigitalOcean:**
  1. Push your code to GitHub.
  2. Configure the deployment settings and environment variables.
  3. Deploy your application following the provider's guidelines.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Commit your changes and push to your fork.
4. Open a pull request with a detailed description of your changes.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- Inspired by modern Rails e-commerce practices and digital delivery systems.
- Thanks to the open-source community for tools like Devise, Hotwire, TailwindCSS, and more.
- Image credits to [Unsplash](https://unsplash.com) and icon sets from [Heroicons](https://heroicons.com).

This README.md serves as a robust starting point for developers and collaborators, providing clear setup instructions, technical details, and guidelines for contribution.