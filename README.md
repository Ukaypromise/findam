# FindAm Backend

A Rails 8.0 GraphQL API backend for a property rental platform connecting landlords and tenants. Built with a pure GraphQL API design, Single Table Inheritance (STI) for user polymorphism, and comprehensive authentication workflow.

## Features

- **Pure GraphQL API** - All interactions via `/graphql` endpoint
- **User Polymorphism** - Single Table Inheritance (STI) with three user types: Landlord, Tenant, Admin
- **Devise Authentication** - Integrated with GraphQL Devise for secure token-based auth
- **User Approval Workflow** - Onboarding completion and admin approval system
- **GraphQL Subscriptions** - Real-time updates via Action Cable
- **Background Jobs** - Solid Queue for async processing
- **Caching Layer** - Solid Cache for performance
- **WebSocket Support** - Solid Cable for persistent connections
- **File Upload Support** - Apollo Upload Server integration

## Getting Started

### Prerequisites

- Ruby 3.4+
- PostgreSQL 14+
- Rails 8.0+
- Node.js (for asset handling)

### Installation

1. Clone the repository
2. Install dependencies:

   ```bash
   bundle install
   ```

3. Set up the database:

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # Optional: seed sample data
   ```

4. Start the server:
   ```bash
   bin/dev  # Uses Procfile.dev for development
   # or
   rails server
   ```

### Development Tools

- **GraphiQL** (GraphQL IDE): http://localhost:3000/graphiql (development only)
- **GraphQL Endpoint**: http://localhost:3000/graphql
- **Mission Control** (Job Dashboard): http://localhost:3000/jobs
- **Action Cable**: ws://localhost:3000/cable (WebSocket subscriptions)

## Architecture

### User Model (Single Table Inheritance)

The project uses STI with a single `users` table and three subclasses:

- **User** (base class) - Core authentication and attributes
- **Landlord** (extends User) - Property owners
- **Tenant** (extends User) - Property seekers
- **Admin** (extends User) - System administrators

User Type Selection:

```graphql
enum UserTypeEnum {
  LANDLORD
  TENANT
  ADMIN
}
```

### User Approval Workflow

Users progress through the following states:

1. **Created** (`approval_status: "pending"`)
   - User registers and completes basic setup

2. **Onboarding** (`approval_status: "submitted"`)
   - User completes role-specific onboarding
   - Triggered via `completeOnboarding` mutation

3. **Approval** (Admin action)
   - Approved: `approval_status: "approved"`, `approved_at: timestamp`
   - Rejected: `approval_status: "rejected"`, `rejected_at: timestamp`, `rejection_reason: text`

### Database Schema

**Users Table**

- `type` - STRING (STI column: "User", "Landlord", "Tenant", "Admin")
- `email` - STRING (unique)
- `encrypted_password` - STRING
- `approval_status` - STRING ("pending", "submitted", "approved", "rejected")
- `onboarding_completed` - BOOLEAN
- `onboarding_completed_at` - DATETIME
- `approved_at` - DATETIME (when approved)
- `rejected_at` - DATETIME (when rejected)
- `rejection_reason` - STRING (reason for rejection)
- Devise fields: `confirmation_token`, `confirmed_at`, `reset_password_token`, etc.
- `tokens` - JSON (authentication tokens)

**Profiles Table** (Polymorphic)

- `user_id` - BIGINT (foreign key)
- `profile_type` - STRING (STI: "Profile", "LandlordProfile", "TenantProfile")
- Additional role-specific fields (customizable per profile type)

## GraphQL API Documentation

### Endpoint Details

- **Endpoint**: POST `/graphql`
- **Authentication**: Token-based (JWT) via headers
- **Subscription**: WebSocket at `/cable`

### Authentication Headers

After login/registration, include these headers with all requests:

```
access-token: <access_token>
uid: <uid>
client: <client>
```

Or for GraphiQL in development, set them via:

```javascript
const headers = {
  "access-token": accessToken,
  uid: uid,
  client: client,
};
```

### Key Queries

#### getCurrentUser

```graphql
query {
  currentUser {
    id
    email
    type
    onboardingCompleted
    approvalStatus
    landlordProfile {
      id
    }
    tenantProfile {
      id
    }
  }
}
```

#### nodeInterface (Relay)

```graphql
query {
  node(id: "123") {
    id
    ... on User {
      email
      type
    }
  }
}
```

### Key Mutations

#### User Registration

```graphql
mutation {
  userRegistration(
    email: "user@example.com"
    password: "SecurePass123!"
    passwordConfirmation: "SecurePass123!"
    type: LANDLORD
  ) {
    authenticatable {
      id
      email
      type
      approvalStatus
    }
    credentials {
      accessToken
      uid
      client
    }
  }
}
```

Response:

- `type` can be: LANDLORD, TENANT, or ADMIN
- Returns credentials for authentication
- User profile is auto-created

## Error Handling

GraphQL errors include extensions with detailed information:

```json
{
  "errors": [
    {
      "message": "Error creating user",
      "extensions": {
        "email": ["has already been taken"],
        "password": ["is too short"]
      }
    }
  ]
}
```

Common HTTP Status Codes:

- **200** - Successful query/mutation (even if GraphQL errors)
- **400** - Malformed request
- **401** - Authentication required/invalid
- **500** - Server error

---

## Project Structure

```
app/
├── models/                    # ActiveRecord models
│   ├── user.rb              # Base User (STI)
│   ├── landlord.rb          # Landlord subclass
│   ├── tenant.rb            # Tenant subclass
│   ├── admin.rb             # Admin subclass
│   ├── profile.rb           # Base Profile (STI)
│   ├── landlord_profile.rb  # Landlord-specific profile
│   └── tenant_profile.rb    # Tenant-specific profile
├── graphql/                 # GraphQL schema and types
│   ├── findam_schema.rb     # Main schema definition
│   ├── types/               # GraphQL type definitions
│   │   ├── query_type.rb
│   │   ├── mutation_type.rb
│   │   ├── subscription_type.rb
│   │   ├── base_*.rb        # Base classes
│   │   ├── objects/         # User/Profile types
│   │   └── enums/           # Enum definitions
│   ├── mutations/           # Mutation implementations
│   │   ├── user_registration.rb
│   │   └── complete_onboarding.rb
│   └── resolvers/           # Resolver helpers
├── controllers/
│   ├── graphql_controller.rb    # /graphql endpoint
│   └── application_controller.rb
├── services/
│   └── subscription_manager.rb  # WebSocket subscriptions
└── views/

config/
├── routes.rb                # GraphQL routing
├── environments/            # Environment-specific config
│   ├── development.rb
│   ├── staging.rb
│   └── production.rb
├── initializers/            # Rails initializers
│   ├── devise.rb
│   ├── devise_token_auth.rb
│   └── graphql*.rb
└── credentials.yml.enc      # Encrypted secrets

db/
├── schema.rb                # Database schema
├── migrate/                 # Migration files
│   ├── ..._devise_token_auth_create_users.rb
│   ├── ..._add_type_to_users.rb
│   └── ..._create_profiles.rb
└── seeds.rb                 # Sample data

spec/                        # RSpec tests
├── models/
├── graphql/
├── mutations/
└── factories/               # FactoryBot fixtures
```

---

## Environment Variables

Create `.env` file (or use Rails credentials):

```
# Database
DATABASE_URL=postgresql://user:password@localhost/uniguideme_backend_development

# Email (optional)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=app-password

# API Keys (if applicable)
JWT_SECRET=your-secret-key
```

Load via:

```bash
# Using .env
require 'dotenv/load'

# Or Rails credentials
RAILS_MASTER_KEY=key rails credentials:edit
```

---

## Testing

Run tests with RSpec:

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/graphql/mutations/user_registration_spec.rb

# With coverage
bundle exec rspec --require spec_helper --format documentation --tag coverage_focus
```

Test factories in `spec/factories/`:

```bash
FactoryBot.create(:landlord, email: "landlord@example.com")
FactoryBot.create(:tenant, email: "tenant@example.com")
```

---

## Deployment

### Docker

```bash
# Build image
docker build -t findam-backend .

# Run container
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://... \
  -e RAILS_MASTER_KEY=... \
  findam-backend
```

### Kamal

```bash
# Deploy to production
kamal deploy

# Check status
kamal app details

# View logs
kamal app logs -f
```

### Environment-Specific Deploys

```bash
# Staging
kamal deploy -d deploy.staging.yml

# Production
kamal deploy -d deploy.yml
```

---

## Troubleshooting

### Database Issues

```bash
# Reset database
rails db:drop db:create db:migrate db:seed

# Check migration status
rails db:migrate:status

# Rollback last migration
rails db:rollback
```

### Authentication Issues

- Ensure `access-token`, `uid`, `client` headers are present
- Check token hasn't expired
- Verify user `type` column has correct value ("Landlord", etc.)

### GraphQL Subscription Issues

- Check WebSocket connection to `/cable`
- Verify ActionCable is properly configured
- Test with `subscription { testEvent { message } }`

### GraphiQL Not Loading

- Only available in development/staging environments
- Clear browser cache
- Check `Rails.env` configuration

---

## Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Follow the patterns in `.instructions.md`
3. Write tests for new mutations/queries
4. Run `rubocop` and fix linting issues
5. Commit (`git commit -m 'Add amazing feature'`)
6. Push and create a Pull Request

---

## License

Proprietary - All Rights Reserved

---

## Support

For issues and questions:

- Check `.instructions.md` for detailed architecture guidance
- Review existing mutations/queries for patterns
- Check Rails logs: `tail -f log/development.log`
- GraphQL errors include detailed extensions information

```graphql
mutation RegisterUser {
  userRegistration(
    input: {
      email: "promise@gmail.com"
      password: "password123"
      passwordConfirmation: "password123"
      type: LANDLORD # or TENANT
      # confirmUrl:"https://lvh.me:3006/blah"
    }
  ) {
    authenticatable {
      email
    }
    credentials {
      accessToken
      uid
      client
      expiry
    }
  }
}
```

**Parameters:**

- `confirmUrl` (String, required): URL to redirect user after email confirmation
- `email` (String, required): User's email address
- `password` (String, required): User's password
- `passwordConfirmation` (String, required): Password confirmation (must match password)

**Response:**

```json
{
  "data": {
    "userRegister": {
      "authenticatable": {
        "email": "user@example.com"
      }
    }
  }
}
```

---

### Confirm User Account

Confirm a user's account using the confirmation token sent via email.

**Mutation:**

```graphql
mutation ConfirmUserAccount {
  userConfirmRegistrationWithToken(confirmationToken: "1BgjgJijaYEcZF1Dy7qY") {
    authenticatable {
      email
    }
    credentials {
      accessToken
      uid
      client
    }
  }
}
```

**Parameters:**

- `confirmationToken` (String, required): Token received in confirmation email

**Response:**

```json
{
  "data": {
    "userConfirmRegistrationWithToken": {
      "authenticatable": {
        "email": "user@example.com"
      },
      "credentials": {
        "accessToken": "abc123...",
        "uid": "user@example.com",
        "client": "client_id"
      }
    }
  }
}
```

---

### User Login

Authenticate an existing user and receive authentication credentials.

**Mutation:**

```graphql
mutation LoginUser {
  userLogin(email: "user@example.com", password: "securepassword123") {
    authenticatable {
      email
    }
    credentials {
      accessToken
      uid
      client
    }
  }
}
```

**Parameters:**

- `email` (String, required): User's email address
- `password` (String, required): User's password

**Response:**

```json
{
  "data": {
    "userLogin": {
      "authenticatable": {
        "email": "user@example.com"
      },
      "credentials": {
        "accessToken": "abc123...",
        "uid": "user@example.com",
        "client": "client_id"
      }
    }
  }
}
```

---

### User Logout

Log out the current authenticated user.

**Mutation:**

```graphql
mutation LogoutUser {
  userLogout {
    authenticatable {
      email
    }
  }
}
```

**Authentication Required:** Yes

**Response:**

```json
{
  "data": {
    "userLogout": {
      "authenticatable": {
        "email": "user@example.com"
      }
    }
  }
}
```

---

### Forgot Password Reset

Send a password reset email to the user.

**Mutation:**

```graphql
mutation ForgotPasswordReset {
  userSendPasswordResetWithToken(
    email: "user@example.com"
    redirectUrl: "http://localhost:3000/reset-password"
  ) {
    message
  }
}
```

**Parameters:**

- `email` (String, required): User's email address
- `redirectUrl` (String, required): URL to redirect user after password reset

**Response:**

```json
{
  "data": {
    "userSendPasswordResetWithToken": {
      "message": "You will receive an email with instructions on how to reset your password in a few minutes."
    }
  }
}
```

---

### Reset Password

Reset user's password using the reset token received via email.

**Mutation:**

```graphql
mutation PasswordReset {
  userUpdatePasswordWithToken(
    password: "newpassword123"
    passwordConfirmation: "newpassword123"
    resetPasswordToken: "MQ4xsEYjF1d7iUEwVAS4"
  ) {
    authenticatable {
      email
    }
  }
}
```

**Parameters:**

- `password` (String, required): New password
- `passwordConfirmation` (String, required): Password confirmation (must match password)
- `resetPasswordToken` (String, required): Token received in password reset email

**Response:**

```json
{
  "data": {
    "userUpdatePasswordWithToken": {
      "authenticatable": {
        "email": "user@example.com"
      }
    }
  }
}
```

---

### Resend Confirmation

Resend the account confirmation email to the user.

**Mutation:**

```graphql
mutation ResendConfirmation {
  userResendConfirmationWithToken(
    email: "user@example.com"
    confirmUrl: "https://lvh.me:3006/confirm"
  ) {
    message
  }
}
```

**Parameters:**

- `email` (String, required): User's email address
- `confirmUrl` (String, required): URL to redirect user after confirmation

**Response:**

```json
{
  "data": {
    "userResendConfirmationWithToken": {
      "message": "You will receive an email with instructions for how to confirm your account in a few minutes."
    }
  }
}
```

---

## Queries

### Current User

Get information about the currently authenticated user.

**Query:**

```graphql
query CurrentUser {
  currentUser {
    id
    confirmedAt
    email
    name
  }
}
```

**Authentication Required:** Yes

**Response:**

```json
{
  "data": {
    "currentUser": {
      "id": "gid://uniguideme-backend/User/1",
      "confirmedAt": "2026-01-20T10:30:00Z",
      "email": "user@example.com",
      "name": "John Doe"
    }
  }
}
```

---

### Code Quality

```bash
# RuboCop
bundle exec rubocop

# Brakeman (security)
bundle exec brakeman

# Rails Best Practices
bundle exec rails_best_practices
```
