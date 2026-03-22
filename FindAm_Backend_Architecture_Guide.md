# FindAm Backend Architecture Guide

> **Rails 8.0 · GraphQL API · PostgreSQL · React Native**

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Design Patterns](#2-architecture--design-patterns)
3. [GraphQL API Structure](#3-graphql-api-structure)
4. [Planned Development Areas](#4-planned-development-areas)
5. [Conventions & Coding Standards](#5-conventions--coding-standards)
6. [File Structure Reference](#6-file-structure-reference)
7. [Common Debugging Scenarios](#7-common-debugging-scenarios)

---

## 1. Project Overview

FindAm is a property rental platform connecting landlords and tenants across all major Nigerian cities. It replaces traditional housing agents — who charge 10–15% of annual rent — with a transparent, split-commission digital marketplace. Both tenant and landlord pay a small platform fee only upon a successful rental agreement.

This document describes the backend system architecture, design decisions, and implementation guidelines for developers and AI assistants working on the codebase.

> **Quick Reference**
> - Database: `uniguideme_backend_development`
> - API endpoint: `POST /graphql`
> - GraphiQL IDE: `GET /graphiql` _(development only)_

### 1.1 Core Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Framework | Rails 8.0 / Ruby 3.4 | API server, business logic, background jobs |
| API Protocol | GraphQL (graphql-ruby) | Single endpoint, typed schema, subscriptions |
| Authentication | Devise + GraphQL Devise ~2.1 | JWT token auth via custom mutations |
| Database | PostgreSQL | Primary data store |
| Real-time | Action Cable / Solid Cable | WebSocket subscriptions for chat & notifications |
| Background Jobs | Solid Queue | Email delivery, async processing |
| Caching | Solid Cache | Query results, session data |
| Mobile Client | React Native | Android + iOS from a single codebase |
| Payments | Paystack / Flutterwave | NGN commission processing |
| Identity Verification | Prembly / YouVerify | NIN / BVN API lookups |
| File Storage | AWS S3 / Cloudinary | Property photos and ID documents |

### 1.2 Business Context

FindAm removes traditional property agents and replaces them with a split-commission model:

- **Tenant pays** ~2–3% of annual rent on successful move-in confirmation
- **Landlord pays** ~1–2% when their listing is successfully rented
- No upfront listing fee — removes the barrier for landlords to join early
- Optional premium listings for top-of-search visibility (secondary revenue)

---

## 2. Architecture & Design Patterns

### 2.1 Single Table Inheritance (STI) — User Model

The user system uses Rails STI to store all user types in a single `users` table. A `type` column holds the class name string and Rails automatically instantiates the correct subclass when records are loaded.

```
User (base — Devise authentication, shared fields)
├── Landlord   (type = 'Landlord')
├── Tenant     (type = 'Tenant')
└── Admin      (type = 'Admin')
```

**Key files:**

- `app/models/user.rb` — Base User model with Devise
- `app/models/landlord.rb` — Landlord STI subclass
- `app/models/tenant.rb` — Tenant STI subclass
- `app/models/admin.rb` — Admin STI subclass

#### STI Key Fields

| Column | Type | Description |
|---|---|---|
| `type` | STRING | STI discriminator — `'Landlord'`, `'Tenant'`, `'Admin'` |
| `approval_status` | STRING | Workflow state: `pending → submitted → approved / rejected` |
| `onboarding_completed` | BOOLEAN | `true` once the user finishes their profile setup flow |
| `onboarding_completed_at` | DATETIME | Timestamp when onboarding was completed |
| `uid` / `provider` | STRING | Unique auth identifier, supports email + OAuth |
| `tokens` | JSON | GraphQL Devise JWT token store |
| `email` | STRING | Unique, used as the login identifier |
| `encrypted_password` | STRING | Devise-managed |
| `rejection_reason` | STRING | Set when an admin rejects a user application |

#### User Helper Methods

```ruby
user.landlord?          # => true/false
user.tenant?            # => true/false
user.admin?             # => true/false
user.approve!           # Sets approval_status = "approved", approved_at = Time.current
user.reject!(reason:)   # Sets approval_status = "rejected", stores rejection_reason
```

### 2.2 Profile Models

Every user has an associated profile created automatically via an `after_create` callback. Profiles are polymorphic, extending a base `Profile` with subtype-specific fields.

```
Profile (base — shared fields: avatar, bio, phone)
├── LandlordProfile  — NIN verified, ownership documents, bank account
└── TenantProfile    — employment info, emergency contact
```

**Relationships:**

```ruby
User       has_one :profile,          dependent: :destroy
Landlord   has_one :landlord_profile
Tenant     has_one :tenant_profile
```

> ⚠️ **Profiles are auto-created on User creation via `after_create :create_profile`. Never create them manually outside of model callbacks.**

### 2.3 Approval Workflow

Every landlord (and optionally tenant) must pass a multi-stage approval flow before their account is fully active. This is the primary fraud-prevention mechanism.

```
User Created
     │
     ▼
 [pending]  ──── completeOnboarding mutation ────▶  [submitted]
                                                          │
                                              Admin reviews profile
                                                    │         │
                                                    ▼         ▼
                                              [approved]  [rejected]
                                                              │
                                                    User corrects & re-submits
```

| State | Trigger | What It Means |
|---|---|---|
| `pending` | User created | Account exists but onboarding not started |
| `submitted` | `completeOnboarding` mutation | User submitted their profile for admin review |
| `approved` | Admin calls `user.approve!` | Full platform access granted |
| `rejected` | Admin calls `user.reject!(reason:)` | User notified with reason; can re-submit |

### 2.4 Real-time Architecture

WebSocket connections are handled by Action Cable backed by Solid Cable (database-backed, no Redis required). Subscriptions power:

- **Chat messages** — delivered instantly to the other party's device
- **Inspection bookings** — landlord receives real-time slot request
- **Approval status** — tenant/landlord notified when admin approves or rejects
- **New listing alerts** — tenants subscribed to a search receive push notifications

---

## 3. GraphQL API Structure

### 3.1 Endpoints

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/graphql` | Primary API endpoint for all queries, mutations, subscriptions |
| `GET` | `/graphiql` | Interactive GraphQL IDE — development only |
| `POST` | `/graphql_auth/*` | Devise authentication endpoints |

### 3.2 Type System

```
app/graphql/types/
├── query_type.rb               — currentUser, node, nodes
├── mutation_type.rb            — registers all mutations
├── subscription_type.rb        — real-time subscriptions
├── node_type.rb
├── base_*.rb                   — base classes for all types
├── objects/
│   ├── user_type.rb            — base user (all shared fields)
│   ├── landlord_type.rb        — landlord-specific fields
│   ├── tenant_type.rb          — tenant-specific fields
│   ├── listing_type.rb         — property listing
│   ├── profile_type.rb         — base profile
│   ├── landlord_profile_type.rb
│   └── tenant_profile_type.rb
└── enums/
    └── user_type_enum_type.rb  — LANDLORD | TENANT | ADMIN
```

### 3.3 Authentication Model

Authentication uses JWT tokens issued by GraphQL Devise. Tokens are sent as request headers. Inside any mutation or resolver, the current user is accessed via `context[:current_resource]`.

> ⚠️ **All mutations that require login must check `context[:current_resource]`. Use `authenticate: false` only for registration and public queries.**

#### Token Flow

1. Client sends `userRegistration` or `login` mutation
2. Backend returns `credentials: { access_token, token_type, uid, client }`
3. Client stores credentials and sends them as headers on every subsequent request
4. Backend middleware hydrates `context[:current_resource]` from headers
5. Mutations/resolvers access `context[:current_resource]` to get the logged-in user

#### Example: Authenticated Request Headers

```
access-token: <token>
token-type:   Bearer
uid:          user@example.com
client:       <client_id>
```

### 3.4 Mutation Pattern

All mutations extend `Mutations::BaseMutation`, which itself extends `GraphQL::Schema::RelayClassicMutation`. This enforces a consistent input/output contract across the entire API.

```ruby
class Mutations::ExampleMutation < BaseMutation
  # Arguments are validated before resolve is called
  argument :field_name, String, required: true

  # Return fields — always include errors
  field :result_object, Types::Objects::SomeType, null: true
  field :errors, [String], null: false

  def resolve(field_name:)
    current_user = context[:current_resource]
    # ... business logic
    { result_object: obj, errors: [] }
  rescue => e
    raise GraphQL::ExecutionError.new(e.message)
  end
end
```

Then register in `Types::MutationType`:

```ruby
field :example_mutation, mutation: Mutations::ExampleMutation
```

### 3.5 Current Mutations Reference

| Mutation | Auth Required | Description |
|---|---|---|
| `userRegistration` | No | Creates Landlord, Tenant, or Admin. Returns JWT credentials. |
| `completeOnboarding` | Yes | Marks onboarding complete, sets `approval_status` to `submitted`. |
| `login` | No | Devise built-in — returns JWT credentials for existing users. |
| `logout` | Yes | Invalidates the current token. |
| `updatePasswordWithToken` | Token | Password reset via emailed token. |

#### userRegistration Example

```graphql
mutation {
  userRegistration(
    email: "landlord@example.com"
    password: "secret123"
    passwordConfirmation: "secret123"
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
      tokenType
      uid
      client
    }
  }
}
```

### 3.6 Query Type

```graphql
query {
  currentUser {
    id
    email
    type
    approvalStatus
    onboardingCompleted
    landlordProfile { ... }
    tenantProfile { ... }
  }

  node(id: "ID") { ... }
  nodes(ids: ["ID"]) { ... }
}
```

---

## 4. Planned Development Areas

### 4.1 Property Listings

#### Data Model

- `Listing` belongs_to `Landlord` (STI user)
- Fields: `title`, `description`, `price`, `address`, `city`, `property_type`, `bedrooms`, `bathrooms`, `is_available`
- Photos via Active Storage → Cloudinary / AWS S3
- Geolocation: `latitude`, `longitude` for map-based search

#### GraphQL Additions

| Addition | Type | Notes |
|---|---|---|
| `listings(city:, priceMin:, priceMax:, type:, page:)` | Query | Paginated search |
| `listing(id:)` | Query | Single listing detail |
| `createListing` | Mutation | Landlord only, requires `approved` status |
| `updateListing` / `deleteListing` | Mutation | Owner only |
| `toggleListingAvailability` | Mutation | Mark listing as rented |

### 4.2 In-App Messaging

#### Architecture

- `Message` model: `sender` (User), `recipient` (User), `listing` (Listing), `body`, `read_at`
- Conversations scoped per listing to prevent cross-listing confusion
- Phone numbers hidden until both parties explicitly agree to share
- Real-time delivery via Action Cable subscription

#### GraphQL Additions

```graphql
# Queries
conversations                          # All conversations for current user
messages(conversationId: ID!)          # Paginated message history

# Mutations
sendMessage(recipientId: ID!, listingId: ID!, body: String!)
markMessagesRead(conversationId: ID!)

# Subscriptions
messageReceived(conversationId: ID!)
```

### 4.3 Inspection Booking

#### Data Model

- `InspectionSlot` belongs_to `Landlord` — available time windows
- `InspectionBooking`: `tenant`, `landlord`, `listing`, `slot`, `status` (`pending` / `confirmed` / `cancelled`)
- Calendar export: iCal format

#### GraphQL Additions

```graphql
# Queries
availableSlots(listingId: ID!)         # Returns open inspection windows

# Mutations
createInspectionSlot(...)              # Landlord sets availability
bookInspection(slotId: ID!, listingId: ID!)   # Tenant requests slot
confirmInspection(bookingId: ID!)     # Landlord confirms
cancelInspection(bookingId: ID!)      # Either party cancels

# Subscriptions
inspectionStatusChanged(bookingId: ID!)
```

### 4.4 Landlord Verification (Trust Badges)

| Badge | Requirement | Implementation |
|---|---|---|
| **Verified** | NIN / BVN check | Prembly or YouVerify API, stores `verified_at` timestamp |
| **Certified** | Property ownership document | Admin reviews C of O / deed, sets `certified_at` |
| **Top Landlord** | 3+ deals, 4.5+ rating | Computed field on `LandlordProfile`, recalculated nightly via Solid Queue |

### 4.5 Commission & Payments

- `CommissionPayment` model: `listing`, `tenant`, `landlord`, `amount`, `tenant_split_%`, `landlord_split_%`, `status`, `paid_at`
- Paystack (primary) or Flutterwave webhook listener sets payment status
- Commission triggered when both parties confirm rental agreement in-app

```graphql
# Mutations
initiatePayment(listingId: ID!)        # Creates Paystack payment link

# Webhook (REST — exempt from CSRF)
POST /webhooks/paystack                # Updates CommissionPayment status
```

### 4.6 Admin Dashboard

```graphql
# Queries
pendingApprovals                       # Users awaiting admin review
platformStats                          # Total users, listings, monthly revenue
flaggedListings                        # Fraud reports

# Mutations
approveUser(userId: ID!)
rejectUser(userId: ID!, reason: String!)
suspendUser(userId: ID!, reason: String!)
```

---

## 5. Conventions & Coding Standards

### 5.1 Naming Conventions

| Context | Convention | Example |
|---|---|---|
| GraphQL Types | Singular, PascalCase | `Types::Objects::ListingType` |
| GraphQL Enums | Ends with `EnumType` | `Types::Enums::UserTypeEnumType` |
| GraphQL Mutations | VerbNoun, PascalCase | `Mutations::CreateListing` |
| GraphQL Fields | camelCase in schema | `approvalStatus`, `listingId` |
| Ruby Models | Singular, PascalCase | `Listing`, `InspectionSlot` |
| Ruby Methods | snake_case | `approval_status`, `create_profile` |
| Database Tables | Plural, snake_case | `listings`, `inspection_slots` |

> GraphQL automatically converts Ruby `snake_case` fields to `camelCase` in the schema. No manual aliasing needed.

### 5.2 GraphQL Field Rules

- Use `null: false` for fields that are always present — enforces schema contracts at runtime
- Use `null: true` for optional relationships and computed fields
- Always return `errors: []` as a field in mutation responses alongside the primary object
- Never expose internal Rails errors directly — wrap them in `GraphQL::ExecutionError`

### 5.3 Error Handling

```ruby
# Preferred: structured error with model validation extensions
raise GraphQL::ExecutionError.new(
  'Validation failed',
  extensions: model.errors.to_hash
)

# For authorisation errors
raise GraphQL::ExecutionError.new('Not authorized')

# In mutation response (always include errors field)
field :user,   Types::Objects::UserType, null: true
field :errors, [String], null: false

def resolve(...)
  { user: user, errors: [] }
rescue ActiveRecord::RecordInvalid => e
  { user: nil, errors: e.record.errors.full_messages }
end
```

### 5.4 Adding a New Mutation (Checklist)

1. Create `app/graphql/mutations/mutation_name.rb`
2. Extend `Mutations::BaseMutation`
3. Declare arguments with types and `required: true/false`
4. Declare return fields including `errors: [String], null: false`
5. Implement `resolve` method; access current user via `context[:current_resource]`
6. Register in `Types::MutationType`:
   ```ruby
   field :mutation_name, mutation: Mutations::MutationName
   ```
7. Write RSpec tests covering: success, validation failure, and auth failure

### 5.5 Rules — What NOT To Do

> 🚫 **Never create REST endpoints.** This is a pure GraphQL API — all interactions go through `/graphql`.

> 🚫 **Never modify the `type` column.** It is the STI discriminator. Removing or renaming it breaks the entire user polymorphism system.

> 🚫 **Never bypass authentication middleware.** All protected mutations must check `context[:current_resource]`.

> 🚫 **Never create profiles manually.** The `after_create` callback on `User` handles this automatically.

> 🚫 **Never modify GraphQL Devise configuration directly.** Prefer custom mutations over framework-level mutations.

> 🚫 **Never use `authenticate: false`** unless the mutation is genuinely public (registration, password reset).

---

## 6. File Structure Reference

```
app/
├── models/
│   ├── user.rb                         # Base user: Devise + STI
│   ├── landlord.rb                     # STI: type='Landlord'
│   ├── tenant.rb                       # STI: type='Tenant'
│   ├── admin.rb                        # STI: type='Admin'
│   ├── profile.rb                      # Base profile (shared fields)
│   ├── landlord_profile.rb             # NIN, documents, bank details
│   ├── tenant_profile.rb               # Employment, emergency contact
│   ├── listing.rb                      # Property listing
│   ├── message.rb                      # In-app chat
│   ├── inspection_slot.rb              # Landlord availability windows
│   └── inspection_booking.rb          # Tenant inspection request
│
├── graphql/
│   ├── findam_schema.rb                # Root schema
│   ├── types/
│   │   ├── query_type.rb
│   │   ├── mutation_type.rb
│   │   ├── subscription_type.rb
│   │   ├── node_type.rb
│   │   ├── base_*.rb                   # Base classes for all types
│   │   ├── objects/                    # GraphQL object types
│   │   │   ├── user_type.rb
│   │   │   ├── landlord_type.rb
│   │   │   ├── tenant_type.rb
│   │   │   ├── listing_type.rb
│   │   │   ├── profile_type.rb
│   │   │   ├── landlord_profile_type.rb
│   │   │   └── tenant_profile_type.rb
│   │   └── enums/
│   │       └── user_type_enum_type.rb  # LANDLORD | TENANT | ADMIN
│   ├── mutations/
│   │   ├── base_mutation.rb
│   │   ├── user_registration.rb
│   │   ├── complete_onboarding.rb
│   │   └── ...                         # Future mutations here
│   └── resolvers/
│       └── base_resolver.rb
│
├── controllers/
│   ├── graphql_controller.rb           # Handles POST /graphql
│   ├── webhooks_controller.rb          # Paystack / Flutterwave callbacks
│   └── application_controller.rb
│
├── services/
│   ├── subscription_manager.rb         # WebSocket subscription helpers
│   ├── verification_service.rb         # NIN/BVN API integration
│   └── payment_service.rb             # Paystack / Flutterwave wrapper
│
└── jobs/
    ├── send_notification_job.rb
    └── recalculate_landlord_tier_job.rb
```

---

## 7. Common Debugging Scenarios

| Symptom | Solution |
|---|---|
| User type not recognised in GraphQL | Confirm `type` column contains exact class name: `'Landlord'`, `'Tenant'`, `'Admin'` — not lowercase or enum values. |
| `context[:current_resource]` is nil | Check that auth headers (`access-token`, `uid`, `client`) are included in the request. GraphQL Devise middleware may not be running. |
| Profile not auto-created | Verify `after_create :create_profile` callback is present in `user.rb` and that profile type logic correctly maps to `Landlord`/`Tenant` subtype. |
| GraphQL field name mismatch | Expected behaviour. `snake_case` Ruby fields are auto-converted to `camelCase` in the schema. Use `approvalStatus` in queries, not `approval_status`. |
| Subscription not firing | Confirm Action Cable is connected and Solid Cable is configured. Check that the subscription trigger matches the mutation event name exactly. |
| Payment webhook not received | Ensure `POST /webhooks/paystack` is exempt from CSRF protection and that Paystack signature verification is passing. |
| STI subclass not loading | Ensure all STI subclass files are eager-loaded. In development, check `config/application.rb` eager load paths. |

### 7.1 Changelog

| Migration / Date | Change |
|---|---|
| `20260322131723` | Added `type` column to users table — STI discriminator for Landlord / Tenant / Admin |
| Mar 2026 | Implemented User STI subclasses, approval workflow fields, custom `userRegistration` mutation, `UserTypeEnumType` |

---

*FindAm Backend Architecture Guide — Confidential*
