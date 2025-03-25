# DigitalStore - Technical Documentation

## Overview

DigitalStore is a modern e-commerce platform built with Ruby on Rails 8, designed specifically for selling and delivering digital products. The application provides a seamless shopping experience with integrated payment options including direct mobile money (Momo) for Ghana and Nigeria, alongside Stripe for card payments.

This documentation provides a comprehensive guide to the application's architecture, features, and implementation details, aimed at developers who need to understand, maintain, or extend the codebase.

## Table of Contents

1. [Architecture](#architecture)
   - [Backend](#backend)
   - [Frontend](#frontend)
   - [Database](#database)
2. [Authentication & Authorization](#authentication--authorization)
3. [Core Features](#core-features)
   - [User Management](#user-management)
   - [Session Management](#session-management)
   - [User Interface](#user-interface)
   - [Dark Mode](#dark-mode)
4. [Stimulus Controllers](#stimulus-controllers)
5. [Views](#views)
6. [Routes](#routes)
7. [Testing](#testing)
8. [Deployment](#deployment)
9. [Development Practices](#development-practices)

## Architecture

DigitalStore follows the Model-View-Controller (MVC) architectural pattern with a strong emphasis on domain-driven design principles. The application is structured to maintain a clear separation of concerns, making it scalable and maintainable.

### Backend

The backend is built with Ruby on Rails 8, leveraging its conventions for rapid development. Key components include:

- **Ruby on Rails 8**: The core framework, providing the MVC architecture, routing, and ORM.
- **Devise**: Handles user authentication, registration, and session management.
- **PostgreSQL**: Used as the primary database.
- **Active Storage**: Manages file attachments, particularly for profile pictures and digital products.

### Frontend

The frontend uses modern web technologies for a responsive and interactive user experience:

- **TailwindCSS**: For utility-first styling, enabling responsive design.
- **Hotwire**: Combines Turbo and Stimulus to create a SPA-like experience.
  - **Turbo**: Provides accelerated page navigation and form submissions.
  - **Stimulus**: Manages JavaScript behavior in a structured way.
- **Import Maps**: Manages JavaScript dependencies without a build step.

### Database

The application uses PostgreSQL as its primary database, with tables for:

- **Users**: Stores user account information.
- **Products**: Contains details about the digital products for sale.
- **Active Storage**: Manages file attachments.

## Authentication & Authorization

Authentication is handled by Devise, providing a secure and feature-rich user management system:

- **Registration**: Users can create accounts with email, password, and profile details.
- **Sessions**: Secure login with remember-me functionality.
- **Password Recovery**: Password reset via email.
- **Session Management**: Users can view and manage active sessions across devices.

## Core Features

### User Management

Users can:
- Create accounts with email, password, and profile details.
- Upload profile pictures.
- Manage personal information.
- Update security settings like passwords.

Implementation details:
- User data is stored in the `users` table.
- The `User` model extends Devise with custom methods like `full_name`.
- Profile pictures are stored using Active Storage.

### Session Management

The application includes advanced session management capabilities:

- **Session Tracking**: Users can see all active sessions across devices.
- **Session Termination**: Ability to sign out from specific devices or all other devices.
- **Security Information**: Shows device, browser, and approximate location information.

Implementation details:
- The `sessions_controller.js` handles frontend session management.
- Devise's authentication is extended with custom session tracking.
- The sessions index page provides a user-friendly interface for managing sessions.

### User Interface

The user interface is designed to be:
- **Responsive**: Works well on devices of all sizes.
- **Intuitive**: Follows modern UX patterns for e-commerce.
- **Accessible**: Adheres to basic accessibility principles.

### Dark Mode

The application supports a dark mode toggle:
- Persists user preference via localStorage.
- Automatically detects and respects system preferences.
- Provides visual feedback for the current theme.

Implementation details:
- The `dark_mode_controller.js` manages theme toggling and persistence.
- TailwindCSS's dark mode support is used for styling.

## Stimulus Controllers

The application uses several Stimulus controllers to manage client-side behavior:

1. **`registration_validation_controller.js`**: Handles real-time validation for registration forms.
   - Validates email formats.
   - Provides password strength indicators.
   - Ensures matching password confirmation.

2. **`session_validation_controller.js`**: Manages login form validation.
   - Validates required fields.
   - Provides real-time feedback.
   - Controls submit button state.

3. **`session_manager_controller.js`**: Handles the sessions management interface.
   - Manages session termination.
   - Provides visual feedback for actions.
   - Handles empty states.

4. **`dark_mode_controller.js`**: Manages theme preferences.
   - Toggles between light and dark themes.
   - Persists user preferences.
   - Syncs with system preferences.

5. **`profile_upload_controller.js`**: Manages profile picture uploads.
   - Handles file selection.
   - Displays preview images.
   - Shows file information.

6. **`mobile_menu_controller.js`**: Controls mobile navigation.
   - Handles menu opening/closing.
   - Manages transitions and animations.

7. **`dropdown_controller.js`**: Manages dropdown menus.
   - Toggle dropdown visibility.
   - Handles outside clicks.

8. **`flash_messages_controller.js`**: Handles flash messages.
   - Auto-dismisses messages.
   - Provides animations.

## Views

The application's views are organized into several key areas:

1. **User Management**: 
   - Registration (`registrations/new.html.erb`)
   - Account settings (`registrations/edit.html.erb`)
   - Login (`sessions/new.html.erb`)
   - Sessions management (`sessions/index.html.erb`)

2. **Main Application**:
   - Home page (`home/index.html.erb`)
   - Dashboard (`dashboard/index.html.erb`)
   - Products listing (`products/index.html.erb`)

3. **Support Pages**:
   - Contact (`pages/contact.html.erb`)
   - Help center (`pages/help.html.erb`, `pages/help_category.html.erb`, `pages/help_article.html.erb`)

All views use TailwindCSS for styling, with a component-based approach for reusable elements such as cards, buttons, and forms.

## Routes

The application's routes are defined in `config/routes.rb`:

- `root to: "home#index"`: Main landing page.
- `devise_for :users`: User authentication routes.
- `get 'users/sessions', to: 'devise/sessions#index', as: 'user_sessions'`: Custom session management page.
- `resources :products, only: [:index]`: Product listing page.
- `get "dashboard", to: "dashboard#index", as: :dashboard`: User dashboard.
- `get "contact", to: "pages#contact", as: :contact`: Contact page.
- `post '/contact', to: 'pages#contact_submit', as: 'contact_submit'`: Contact form submission.
- `get "help"`, `get "help/:category"`, `get "help/:category/:article"`: Help center pages.

## Testing

The application includes a testing framework using:

- **Rails testing framework**: For model, controller, and integration tests.
- **Capybara**: For system tests.
- **Selenium WebDriver**: For browser automation.

## Deployment

The application is designed to be deployed using Docker containers with Kamal:

- **Dockerfile**: Defines the container build.
- **Kamal**: Handles deployment orchestration.
- **Thruster**: Provides HTTP asset caching/compression and X-Sendfile acceleration.

Recommended deployment platforms include:
- Fly.io
- Render
- DigitalOcean

## Development Practices

The project follows these development practices:

1. **Domain-Driven Design**: 
   - Focuses on modeling the domain accurately.
   - Uses ubiquitous language across the codebase.
   - Organizes code by domain concerns rather than technical layers.

2. **Code Quality**:
   - Uses RuboCop for code style enforcement.
   - Brakeman for security vulnerability detection.
   - Clear naming conventions and documentation.

3. **Git Workflow**:
   - Feature branches (e.g., `feature/landing-page-authentication`).
   - Development and main branches for different environments.
   - Meaningful commit messages.

4. **Security**:
   - Secure user authentication with Devise.
   - Password strength requirements.
   - Session management and timeout.
   - CSRF protection.

This documentation serves as a comprehensive guide to the DigitalStore application. For specific implementation details, refer to the individual files and their comments.
