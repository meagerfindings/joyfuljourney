# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

**Joyful Journey** is a Ruby on Rails 7.0.8 application that serves as a family memory-sharing platform. Users can create posts to capture memories, with a focus on family relationships and roles (parents, children, grandparents). The app uses PostgreSQL for data persistence and follows standard Rails MVC architecture.

## Development Environment Setup

### Docker-based Development
The application uses Docker for all environments. The current branch `maintenance/dockerize` has Docker configurations:

```bash
# Development
docker-compose -f docker-compose.dev.yml up

# Production  
docker-compose -f docker-compose.prod.yml up

# Testing
docker-compose -f docker-compose.test.yml up
```

**Important**: Create a `.env` file with `POSTGRES_PASSWORD=your_password` before running Docker Compose.

### Ruby and Rails Versions
- Ruby: 3.2.2
- Rails: 7.0.8
- Database: PostgreSQL

## Key Commands

### Database Operations
```bash
# Create and setup database
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed

# Reset database
bundle exec rake db:reset
```

### Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/path/to/file_spec.rb

# Run tests with coverage
bundle exec rspec --format documentation
```

### Code Quality
```bash
# Run linter
bundle exec rubocop

# Fix auto-correctable issues
bundle exec rubocop -a
```

### Rails Server (non-Docker)
```bash
# Start development server
bundle exec rails server
# Access at http://localhost:3000
```

## Core Architecture

### Authentication System
The application implements a unique two-tier user system:
- **Unclaimed Users**: Created without credentials, get random username/password
- **Claimed Users**: Full registration with user-provided credentials

Authentication is session-based using `session[:user_id]` with `current_user` helper available throughout the application.

### Main Models and Relationships

**User Model**:
- Fields: `first_name`, `last_name`, `username`, `password_digest`, `claimed`, `role`
- Roles: `default` (0), `manager` (1), `admin` (2) 
- Uses bcrypt for password encryption
- Has many posts (note: association defined as `has_many :post` - should be `:posts`)

**Post Model**:
- Fields: `title`, `body`, `user_id`
- Belongs to user
- Validates title presence and body minimum length (10 characters)

### Key Routes
```ruby
root "welcome#index"
resources :posts
resources :users do
  resources :posts, only: [:index]  # Nested user posts
end
get "/login", to: "users#login_form"
post "/login", to: "users#login"  
post "/logout", to: "users#logout"
```

### Controllers and Actions
- **ApplicationController**: Base controller with authentication helpers
- **UsersController**: Full CRUD + login/logout functionality
- **PostsController**: Full CRUD operations
- **WelcomeController**: Landing page

## Testing Framework

The application uses RSpec with comprehensive test coverage:
- **Feature tests** using Capybara for end-to-end testing
- **Controller tests** with rails-controller-testing
- **Model tests** with shoulda-matchers
- **Factory Bot** for test data generation
- **Database Cleaner** for test isolation

Test files are organized in `spec/` with:
- `spec/features/` - Integration tests
- `spec/controllers/` - Controller tests  
- `spec/models/` - Model tests
- `spec/factories/` - Factory definitions

## Database Schema

Current schema includes:
- **users**: Profile fields, authentication, roles, claimed status
- **posts**: Title, body, user association

The database uses PostgreSQL with separate databases for development, test, and production environments.

## Known Issues to Address

1. **Model Association**: User model has `has_many :post` instead of `:posts`
2. **Docker Environment Variables**: Development Dockerfile incorrectly sets `RAILS_ENV='production'`
3. **Missing Migration**: Role column exists in schema without corresponding migration file
4. **Hardcoded Values**: Posts controller has TODO about hardcoded user assignment
5. **Authorization**: Role system exists but not enforced in controllers

## Development Workflow

1. The application follows standard Rails conventions
2. Use Docker for consistency across environments
3. Run tests before committing changes
4. Follow existing code patterns and naming conventions
5. The app is currently on `maintenance/dockerize` branch - main branch is `main`

## Technology Stack

- **Backend**: Rails 7.0.8, PostgreSQL, BCrypt
- **Frontend**: Hotwire (Turbo + Stimulus), ERB templates
- **Testing**: RSpec, Capybara, Factory Bot
- **Development**: Docker, Puma, Rubocop