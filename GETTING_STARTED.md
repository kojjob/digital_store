# DigitalStore - Getting Started Guide

This guide will help new developers set up the DigitalStore application for local development and understand the key components and workflows.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby**: Version 3.0 or higher
- **Rails**: Version 8.0.2
- **PostgreSQL**: Version 12 or higher
- **Node.js**: Version 18 or higher
- **Yarn**: Latest version
- **Git**: Latest version

## Setting Up the Development Environment

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/digital_store.git
cd digital_store
```

### 2. Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
yarn install
```

### 3. Database Setup

```bash
# Create the database
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed the database with sample data
rails db:seed
```

### 4. Environment Variables

Create a `.env` file in the root directory with the following variables:

```dotenv
# Development database
DATABASE_URL=postgres://localhost/digital_store_development

# Development credentials
# RAILS_MASTER_KEY=your_master_key

# For Momo and Stripe integrations (when implementing)
# MOMO_MTN_API_KEY=your_mtn_api_key
# STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
# STRIPE_SECRET_KEY=your_stripe_secret_key
```

### 5. Start the Development Server

```bash
# Start the Rails server
bin/dev
```

This command uses Foreman (via the `bin/dev` script) to start both the Rails server and the Tailwind CSS compiler.

Visit [http://localhost:3000](http://localhost:3000) in your browser to see the application.

## Project Structure

### Key Directories

- `app/` - Contains the core application code
  - `controllers/` - Controllers that handle requests
  - `models/` - ActiveRecord models
  - `views/` - ERB templates and layouts
  - `javascript/` - Stimulus controllers and JavaScript code
  - `assets/` - CSS, images, and other assets
- `config/` - Configuration files
- `db/` - Database migrations and schema
- `test/` - Test files

### Important Files

- `Gemfile` - Ruby dependencies
- `config/routes.rb` - Application routes
- `app/models/user.rb` - User model with Devise configuration
- `app/javascript/controllers/` - Stimulus controllers

## Key Features and How to Work with Them

### Authentication (Devise)

The application uses Devise for authentication. Key files:

- `app/models/user.rb` - User model with Devise modules
- `app/views/devise/` - Customized Devise views
- `config/initializers/devise.rb` - Devise configuration

To create a test user:

```ruby
User.create!(
  email: 'test@example.com',
  password: 'password123',
  first_name: 'Test',
  last_name: 'User'
)
```

### Frontend with Stimulus

The application uses Stimulus for JavaScript behaviors. Key controllers:

- `app/javascript/controllers/registration_validation_controller.js` - Form validation for registration
- `app/javascript/controllers/session_validation_controller.js` - Login form validation
- `app/javascript/controllers/dark_mode_controller.js` - Dark mode toggle

To add a new Stimulus controller:

1. Create a new file in `app/javascript/controllers/`
2. Register the controller in your HTML with `data-controller="your-controller-name"`

### Styling with TailwindCSS

The application uses TailwindCSS for styling:

- Configuration is in `tailwind.config.js`
- CSS entry point is in `app/assets/stylesheets/application.css`
- Custom styles can be added to TailwindCSS layers

### Session Management

The application includes a custom session management page:

- `app/views/devise/sessions/index.html.erb` - Session listing and management
- `app/javascript/controllers/session_manager_controller.js` - Frontend behavior

## Development Workflow

### Git Workflow

1. Always work on feature branches
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make small, focused commits
   ```bash
   git commit -m "Add validation to registration form"
   ```

3. Push your branch and create a pull request
   ```bash
   git push origin feature/your-feature-name
   ```

### Testing

Run the test suite before submitting changes:

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/user_test.rb
```

### Code Quality

Ensure your code follows the project's style guide:

```bash
# Run RuboCop
bundle exec rubocop

# Run Brakeman security scan
bundle exec brakeman
```

## Extending the Application

### Adding a New Model

```bash
rails generate model Product name:string description:text price:decimal
```

Don't forget to:
1. Add validations to the model
2. Update the schema with `rails db:migrate`
3. Add tests for the model

### Adding a New Controller and Views

```bash
rails generate controller Products index show
```

Then:
1. Define routes in `config/routes.rb`
2. Implement controller actions
3. Create or modify views in `app/views/products/`

### Adding a New Stimulus Controller

1. Create a new file in `app/javascript/controllers/`, e.g., `product_gallery_controller.js`
2. Implement the controller logic
3. Add `data-controller="product-gallery"` to the relevant HTML element

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Ensure PostgreSQL is running
   - Check database.yml configuration

2. **JavaScript Not Loading**
   - Check browser console for errors
   - Verify importmap.rb includes required libraries

3. **Styling Issues**
   - Run the TailwindCSS watcher (`bin/dev` should do this)
   - Check for CSS class conflicts

### Getting Help

If you encounter issues:
1. Check the error logs in `log/development.log`
2. Review the relevant documentation (Rails, Devise, Stimulus)
3. Ask for help from other team members

## Resources

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)

## Next Steps

After setting up your development environment:

1. Familiarize yourself with the codebase
2. Review the comprehensive [DOCUMENTATION.md](DOCUMENTATION.md)
3. Check the open issues or tasks assigned to you
4. Start with small changes to get comfortable with the workflow

Happy coding!
