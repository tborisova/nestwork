# Nestwork

An interior design project management application built with Ruby on Rails 8. Nestwork helps design firms collaborate with clients on interior design projects by organizing rooms, products, selections, and feedback in one place.

## Features

- **Firm Management**: Design firms can manage their team of designers and clients
- **Project Tracking**: Create and manage projects with status tracking (new, in progress, waiting for approval, done)
- **Room Organization**: Organize projects by rooms with floor plans and product lists
- **Product Management**: Track products with pricing, quantities, links, and approval status
- **Selection Options**: Present multiple options for client decisions (e.g., vanity choices, lighting options)
- **Comments & Collaboration**: Leave comments on rooms, products, and selections for client-designer communication

## Requirements

- Ruby 3.4.2
- SQLite3

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   bin/rails db:create db:migrate
   ```

3. (Optional) Seed the database with sample data:
   ```bash
   bin/rails db:seed
   ```

## Running the Application

Start the Rails server and Tailwind CSS watcher in separate terminals:

```bash
# Terminal 1: Start the Rails server
bin/rails server

# Terminal 2: Watch and compile Tailwind CSS
bin/rails tailwindcss:watch
```

Then visit `http://localhost:3000` in your browser.

## Sample Accounts

After seeding, you can log in with these credentials (password: `password123`):

- **Designer**: `emma@luxeinteriors.com`
- **Client**: `sarah.mitchell@email.com`

## Running Tests

```bash
bin/rails test
```
