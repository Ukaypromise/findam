# FindAm Backend

A Rails 8.0 GraphQL API backend with user authentication powered by GraphQL Devise.

## Features

- GraphQL API with GraphQL Devise authentication
- User registration and authentication
- Password reset functionality
- Email confirmation
- PostgreSQL database
- Solid Queue for background jobs
- Solid Cache for caching
- Solid Cable for Action Cable

## Getting Started

### Prerequisites

- Ruby 3.2+
- PostgreSQL
- Rails 8.0+

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
   ```

4. Start the server:
   ```bash
   rails server
   ```

### Development Tools

- **GraphiQL**: Available at `http://localhost:3000/graphiql` (development only)
- **GraphQL Endpoint**: `http://localhost:3000/graphql`
- **Mission Control Jobs**: Available at `http://localhost:3000/jobs`

## GraphQL API Documentation

### Base URL

- **Development**: `http://localhost:3000/graphql`
- **GraphiQL Interface**: `http://localhost:3000/graphiql` (development only)

### Authentication

This API uses token-based authentication. After successful login or registration, you'll receive authentication credentials that should be included in subsequent requests:

- `accessToken`: Token for authenticating requests
- `uid`: User identifier
- `client`: Client identifier

Include these in your request headers:
```
access-token: <accessToken>
uid: <uid>
client: <client>
```

---

## Mutations

### User Registration

Register a new user account.

**Mutation:**
```graphql
mutation RegUser {
  userRegister(
    confirmUrl: "https://lvh.me:3006/blah"
    email: "user@example.com"
    password: "securepassword123"
    passwordConfirmation: "securepassword123"
  ) {
    authenticatable {
      email
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
  userConfirmRegistrationWithToken(
    confirmationToken: "1BgjgJijaYEcZF1Dy7qY"
  ) {
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
  userLogin(
    email: "user@example.com"
    password: "securepassword123"
  ) {
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
