# FindAm GraphQL API Documentation

## Base URL

- **Development:** `http://localhost:3000/graphql`
- **GraphiQL Interface:** `http://localhost:3000/graphiql` _(development only)_
- **WebSocket (Action Cable):** `ws://localhost:3000/cable`
- **Webhook (REST):** `POST http://localhost:3000/webhooks/paystack`

---

## Authentication

This API uses token-based authentication via GraphQL Devise. After successful login or registration, you'll receive authentication credentials that must be included in all subsequent requests.

### Request Headers

```
access-token: <accessToken>
uid: <uid>
client: <client>
token-type: Bearer
```

---

## User Types

FindAm uses Single Table Inheritance (STI) with three user types:

- **Landlord** — Property owners who list rentals
- **Tenant** — Users searching for rental properties
- **Admin** — Platform administrators

Each user type has an auto-created profile:

- **LandlordProfile** — Verification badges, phone number, bio
- **TenantProfile** — Employment info, emergency contact

When registering, you must specify the user type (`LANDLORD`, `TENANT`, or `ADMIN`). The appropriate profile is automatically created upon registration.

### Approval Workflow

All landlords (and optionally tenants) go through an approval flow:

```
pending → submitted (via completeOnboarding) → approved / rejected (by admin)
```

Only **approved** landlords can create listings.

---

## Mutations

### User Registration

Register a new user account. No authentication required.

**Mutation:**

```graphql
mutation RegisterUser {
  userRegistration(
    input: {
      email: "landlord@example.com"
      password: "password123"
      passwordConfirmation: "password123"
      type: LANDLORD
    }
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

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `email` | String | Yes | User's email address |
| `password` | String | Yes | User's password |
| `passwordConfirmation` | String | Yes | Must match password |
| `type` | Enum | Yes | `LANDLORD`, `TENANT`, or `ADMIN` |

**Response:**

```json
{
  "data": {
    "userRegistration": {
      "authenticatable": {
        "id": "1",
        "email": "landlord@example.com",
        "type": "Landlord",
        "approvalStatus": "pending"
      },
      "credentials": {
        "accessToken": "abc123...",
        "uid": "landlord@example.com",
        "client": "client_id"
      }
    }
  }
}
```

> **Note:** The profile (LandlordProfile or TenantProfile) is automatically created upon registration. Admin users do not get a profile.

---

### Confirm User Account

Confirm a user's account using the confirmation token sent via email.

**Mutation:**

```graphql
mutation ConfirmAccount {
  userConfirmRegistrationWithToken(
    confirmationToken: "abc123token"
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

| Parameter | Type | Required | Description |
|---|---|---|---|
| `confirmationToken` | String | Yes | Token received in confirmation email |

---

### User Login

Authenticate an existing user and receive credentials.

**Mutation:**

```graphql
mutation LoginUser {
  userLogin(
    email: "landlord@example.com"
    password: "password123"
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

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `email` | String | Yes | User's email address |
| `password` | String | Yes | User's password |

---

### User Logout

Log out the current authenticated user.

**Authentication Required:** Yes

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

---

### Forgot Password

Send a password reset email.

**Mutation:**

```graphql
mutation ForgotPassword {
  userSendPasswordResetWithToken(
    email: "user@example.com"
    redirectUrl: "http://localhost:3000/reset-password"
  ) {
    message
  }
}
```

---

### Reset Password

Reset password using the token received via email.

**Mutation:**

```graphql
mutation ResetPassword {
  userUpdatePasswordWithToken(
    password: "newpassword123"
    passwordConfirmation: "newpassword123"
    resetPasswordToken: "reset_token_here"
  ) {
    authenticatable {
      email
    }
  }
}
```

---

### Resend Confirmation

Resend the account confirmation email.

**Mutation:**

```graphql
mutation ResendConfirmation {
  userResendConfirmationWithToken(
    email: "user@example.com"
    confirmUrl: "https://findam.com/confirm"
  ) {
    message
  }
}
```

---

### Complete Onboarding

Submit the user's profile for admin review. Sets `approval_status` to `submitted`.

**Authentication Required:** Yes

**Mutation:**

```graphql
mutation CompleteOnboarding {
  completeOnboarding(input: {}) {
    success
    errors
    landlord {
      id
      email
      onboardingCompleted
      onboardingCompletedAt
      approvalStatus
    }
  }
}
```

**Response:**

```json
{
  "data": {
    "completeOnboarding": {
      "success": true,
      "errors": [],
      "landlord": {
        "id": "1",
        "email": "landlord@example.com",
        "onboardingCompleted": true,
        "onboardingCompletedAt": "2026-03-22T10:30:00Z",
        "approvalStatus": "submitted"
      }
    }
  }
}
```

---

## Property Listings

### Create Listing

Create a new property listing. Only approved landlords can create listings.

**Authentication Required:** Yes (Landlord, approved)

**Mutation:**

```graphql
mutation CreateListing {
  createListing(
    input: {
      title: "Spacious 3 Bedroom Flat in Lekki"
      description: "Beautiful flat with modern amenities, 24hr power, water, and security."
      price: 1500000.00
      address: "12 Admiralty Way, Lekki Phase 1"
      city: "Lagos"
      propertyType: FLAT
      bedrooms: 3
      bathrooms: 2
      latitude: 6.4281
      longitude: 3.4219
      status: PUBLISHED
    }
  ) {
    listing {
      id
      title
      description
      price
      address
      city
      propertyType
      bedrooms
      bathrooms
      isAvailable
      latitude
      longitude
      status
      photos
      document
      createdAt
      landlord {
        id
        email
      }
    }
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `title` | String | Yes | Listing title |
| `description` | String | Yes | Detailed description |
| `price` | Float | Yes | Annual rent price in NGN (must be > 0) |
| `address` | String | Yes | Property address |
| `city` | String | Yes | City name |
| `propertyType` | Enum | Yes | `FLAT`, `DUPLEX`, `BUNGALOW`, `SELF_CONTAIN`, or `ROOM_AND_PARLOUR` |
| `bedrooms` | Integer | No | Number of bedrooms |
| `bathrooms` | Integer | No | Number of bathrooms |
| `latitude` | Float | No | GPS latitude |
| `longitude` | Float | No | GPS longitude |
| `status` | Enum | No | `DRAFT`, `PUBLISHED`, `RENTED`, `REMOVED` (default: `DRAFT`) |
| `photos` | [Upload] | No | Array of photo files (multipart upload) |
| `document` | Upload | No | Supporting property document (multipart upload) |

**Response:**

```json
{
  "data": {
    "createListing": {
      "listing": {
        "id": "1",
        "title": "Spacious 3 Bedroom Flat in Lekki",
        "description": "Beautiful flat with modern amenities...",
        "price": 1500000.0,
        "address": "12 Admiralty Way, Lekki Phase 1",
        "city": "Lagos",
        "propertyType": "flat",
        "bedrooms": 3,
        "bathrooms": 2,
        "isAvailable": true,
        "status": "published",
        "photos": [],
        "document": null,
        "createdAt": "2026-03-22T10:30:00Z",
        "landlord": {
          "id": "1",
          "email": "landlord@example.com"
        }
      },
      "errors": []
    }
  }
}
```

> **File Uploads:** Use the `apollo-upload-client` or multipart form data to send files. Photos accept multiple images; document accepts a single file.

---

### Update Listing

Update an existing listing. Only the owner can update.

**Authentication Required:** Yes (Listing owner)

**Mutation:**

```graphql
mutation UpdateListing {
  updateListing(
    input: {
      id: "1"
      title: "Updated: Spacious 3 Bedroom Flat"
      price: 1800000.00
      status: PUBLISHED
    }
  ) {
    listing {
      id
      title
      price
      status
      updatedAt
    }
    errors
  }
}
```

**Parameters:** Same as `createListing` plus:

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | ID | Yes | Listing ID to update |

All other fields are optional — only provided fields will be updated.

---

### Delete Listing

Soft-delete a listing by setting its status to `removed`. Only the owner can delete.

**Authentication Required:** Yes (Listing owner)

**Mutation:**

```graphql
mutation DeleteListing {
  deleteListing(
    input: {
      id: "1"
    }
  ) {
    listing {
      id
      status
    }
    errors
  }
}
```

**Response:**

```json
{
  "data": {
    "deleteListing": {
      "listing": {
        "id": "1",
        "status": "removed"
      },
      "errors": []
    }
  }
}
```

---

### Toggle Listing Availability

Flip the `isAvailable` flag on a listing. Only the owner can toggle.

**Authentication Required:** Yes (Listing owner)

**Mutation:**

```graphql
mutation ToggleAvailability {
  toggleListingAvailability(
    input: {
      id: "1"
    }
  ) {
    listing {
      id
      isAvailable
    }
    errors
  }
}
```

---

## In-App Messaging

### Send Message

Send a message to another user about a specific listing. Creates a conversation if one doesn't exist.

**Authentication Required:** Yes

**Mutation:**

```graphql
mutation SendMessage {
  sendMessage(
    input: {
      recipientId: "2"
      listingId: "1"
      body: "Hi, is this property still available? I'd like to schedule a viewing."
    }
  ) {
    message {
      id
      body
      senderId
      senderType
      conversationId
      readAt
      createdAt
    }
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `recipientId` | ID | Yes | ID of the user to message |
| `listingId` | ID | Yes | ID of the listing being discussed |
| `body` | String | Yes | Message content |

**Response:**

```json
{
  "data": {
    "sendMessage": {
      "message": {
        "id": "1",
        "body": "Hi, is this property still available?",
        "senderId": 3,
        "senderType": "Tenant",
        "conversationId": 1,
        "readAt": null,
        "createdAt": "2026-03-22T10:30:00Z"
      },
      "errors": []
    }
  }
}
```

> **Note:** Conversations are unique per `[tenant_id, landlord_id, listing_id]` combination. If a conversation already exists for those three, the message is added to it. Otherwise, a new conversation is created automatically.

---

### Mark Messages Read

Mark all unread messages in a conversation as read (messages not sent by the current user).

**Authentication Required:** Yes

**Mutation:**

```graphql
mutation MarkRead {
  markMessagesRead(
    input: {
      conversationId: "1"
    }
  ) {
    conversation {
      id
      lastMessageAt
    }
    errors
  }
}
```

---

## Inspection Booking

### Create Inspection Slot

Landlord creates available time windows for property inspections.

**Authentication Required:** Yes (Landlord only)

**Mutation:**

```graphql
mutation CreateSlot {
  createInspectionSlot(
    input: {
      listingId: "1"
      startsAt: "2026-03-25T10:00:00Z"
      endsAt: "2026-03-25T12:00:00Z"
    }
  ) {
    inspectionSlot {
      id
      listingId
      startsAt
      endsAt
      isBooked
      listing {
        id
        title
      }
    }
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `listingId` | ID | Yes | Listing to create the slot for |
| `startsAt` | ISO8601DateTime | Yes | Slot start time |
| `endsAt` | ISO8601DateTime | Yes | Slot end time (must be after startsAt) |

---

### Book Inspection

Tenant books an available inspection slot.

**Authentication Required:** Yes (Tenant only)

**Mutation:**

```graphql
mutation BookInspection {
  bookInspection(
    input: {
      slotId: "1"
      listingId: "1"
    }
  ) {
    inspectionBooking {
      id
      status
      confirmedAt
      tenant {
        id
        email
      }
      landlord {
        id
        email
      }
      listing {
        id
        title
      }
      inspectionSlot {
        id
        startsAt
        endsAt
      }
    }
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `slotId` | ID | Yes | ID of the inspection slot to book |
| `listingId` | ID | Yes | ID of the listing |

**Response:**

```json
{
  "data": {
    "bookInspection": {
      "inspectionBooking": {
        "id": "1",
        "status": "pending",
        "confirmedAt": null,
        "tenant": { "id": "3", "email": "tenant@example.com" },
        "landlord": { "id": "1", "email": "landlord@example.com" },
        "listing": { "id": "1", "title": "Spacious 3 Bedroom Flat" },
        "inspectionSlot": {
          "id": "1",
          "startsAt": "2026-03-25T10:00:00Z",
          "endsAt": "2026-03-25T12:00:00Z"
        }
      },
      "errors": []
    }
  }
}
```

> **Note:** Booking an inspection automatically marks the slot as booked (`isBooked: true`), preventing double-booking.

---

### Confirm Inspection

Landlord confirms a pending inspection booking.

**Authentication Required:** Yes (Landlord only, booking owner)

**Mutation:**

```graphql
mutation ConfirmInspection {
  confirmInspection(
    input: {
      bookingId: "1"
    }
  ) {
    inspectionBooking {
      id
      status
      confirmedAt
    }
    errors
  }
}
```

**Response:**

```json
{
  "data": {
    "confirmInspection": {
      "inspectionBooking": {
        "id": "1",
        "status": "confirmed",
        "confirmedAt": "2026-03-22T14:00:00Z"
      },
      "errors": []
    }
  }
}
```

---

### Cancel Inspection

Either party (tenant or landlord) can cancel an inspection booking.

**Authentication Required:** Yes (Tenant or Landlord involved in the booking)

**Mutation:**

```graphql
mutation CancelInspection {
  cancelInspection(
    input: {
      bookingId: "1"
      reason: "Something came up, need to reschedule"
    }
  ) {
    inspectionBooking {
      id
      status
      cancelledBy
      cancellationReason
    }
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `bookingId` | ID | Yes | Booking ID to cancel |
| `reason` | String | No | Reason for cancellation |

> **Note:** Cancelling a booking frees up the inspection slot (`isBooked` set back to `false`).

---

## Commission & Payments

### Initiate Payment

Tenant initiates a commission payment for a listing. Creates a Paystack payment link.

**Authentication Required:** Yes (Tenant only)

**Mutation:**

```graphql
mutation InitiatePayment {
  initiatePayment(
    input: {
      listingId: "1"
    }
  ) {
    commissionPayment {
      id
      amount
      tenantPercentage
      landlordPercentage
      status
      paystackReference
      paymentUrl
    }
    paymentUrl
    errors
  }
}
```

**Response:**

```json
{
  "data": {
    "initiatePayment": {
      "commissionPayment": {
        "id": "1",
        "amount": 60000.0,
        "tenantPercentage": 2.5,
        "landlordPercentage": 1.5,
        "status": "pending",
        "paystackReference": "FINDAM-a1b2c3d4e5",
        "paymentUrl": "https://checkout.paystack.com/FINDAM-a1b2c3d4e5"
      },
      "paymentUrl": "https://checkout.paystack.com/FINDAM-a1b2c3d4e5",
      "errors": []
    }
  }
}
```

> **Note:** The commission amount is calculated as 4% of the listing price (2.5% tenant + 1.5% landlord). Redirect the user to `paymentUrl` to complete payment on Paystack.

---

### Confirm Rental Agreement

Both parties must call this mutation to confirm a rental agreement. When both landlord and tenant have confirmed, payment is automatically initiated.

**Authentication Required:** Yes (Landlord or Tenant)

**Mutation:**

```graphql
mutation ConfirmRental {
  confirmRentalAgreement(
    input: {
      listingId: "1"
    }
  ) {
    commissionPayment {
      id
      landlordConfirmedAt
      tenantConfirmedAt
      status
    }
    paymentUrl
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `listingId` | ID | Yes | Listing ID for the rental agreement |

**Flow:**

1. Landlord calls `confirmRentalAgreement` — `landlordConfirmedAt` is set
2. Tenant calls `confirmRentalAgreement` — `tenantConfirmedAt` is set
3. When both confirmations exist, a Paystack payment link is generated and returned in `paymentUrl`

---

### Paystack Webhook (REST)

**This is the only REST endpoint.** Paystack sends payment status updates here.

```
POST /webhooks/paystack
```

- Exempt from CSRF protection
- Verifies Paystack HMAC signature via `X-Paystack-Signature` header
- Updates `CommissionPayment` status to `paid` or `failed`
- Configure this URL in your Paystack dashboard webhook settings

---

## Admin Dashboard

All admin mutations and queries require the current user to be an **Admin** (`type: "Admin"`).

### Approve User

Approve a user's account application. Sends an approval email notification.

**Authentication Required:** Yes (Admin only)

**Mutation:**

```graphql
mutation ApproveUser {
  approveUser(
    input: {
      userId: "2"
    }
  ) {
    user {
      id
      email
      type
      approvalStatus
      approvedAt
    }
    errors
  }
}
```

**Response:**

```json
{
  "data": {
    "approveUser": {
      "user": {
        "id": "2",
        "email": "landlord@example.com",
        "type": "Landlord",
        "approvalStatus": "approved",
        "approvedAt": "2026-03-22T14:00:00Z"
      },
      "errors": []
    }
  }
}
```

---

### Reject User

Reject a user's account application with a reason. Sends a rejection email notification.

**Authentication Required:** Yes (Admin only)

**Mutation:**

```graphql
mutation RejectUser {
  rejectUser(
    input: {
      userId: "2"
      reason: "Incomplete documentation. Please re-upload your property ownership documents."
    }
  ) {
    user {
      id
      email
      approvalStatus
      rejectedAt
      rejectionReason
    }
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `userId` | ID | Yes | User ID to reject |
| `reason` | String | Yes | Reason for rejection |

---

### Suspend User

Suspend a user's account.

**Authentication Required:** Yes (Admin only)

**Mutation:**

```graphql
mutation SuspendUser {
  suspendUser(
    input: {
      userId: "2"
      reason: "Fraudulent listing activity detected"
    }
  ) {
    user {
      id
      email
      approvalStatus
    }
    errors
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `userId` | ID | Yes | User ID to suspend |
| `reason` | String | Yes | Reason for suspension |

---

### Verify Landlord NIN

Verify a landlord's National Identification Number. Calls the Prembly/YouVerify verification service.

**Authentication Required:** Yes (Admin only)

**Mutation:**

```graphql
mutation VerifyNIN {
  verifyLandlordNin(
    input: {
      landlordId: "2"
    }
  ) {
    landlordProfile {
      id
      isNinVerified
      fullName
    }
    errors
  }
}
```

**Response:**

```json
{
  "data": {
    "verifyLandlordNin": {
      "landlordProfile": {
        "id": "1",
        "isNinVerified": true,
        "fullName": "Chukwudi Okafor"
      },
      "errors": []
    }
  }
}
```

---

### Certify Landlord

Certify a landlord after admin reviews property ownership documents (C of O / deed).

**Authentication Required:** Yes (Admin only)

**Mutation:**

```graphql
mutation CertifyLandlord {
  certifyLandlord(
    input: {
      landlordId: "2"
    }
  ) {
    landlordProfile {
      id
      isCertified
      fullName
    }
    errors
  }
}
```

---

## Queries

### Current User

Get the currently authenticated user with their profile.

**Authentication Required:** Yes

**Query for Landlord:**

```graphql
query GetCurrentUser {
  currentUser {
    id
    email
    type
    approvalStatus
    onboardingCompleted
    onboardingCompletedAt
    confirmedAt
    createdAt
    landlordProfile {
      id
      fullName
      location
      shortBio
      phoneNumber
      isNinVerified
      isCertified
      isTopLandlord
      createdAt
      updatedAt
    }
  }
}
```

**Query for Tenant:**

```graphql
query GetCurrentTenant {
  currentUser {
    id
    email
    type
    approvalStatus
    onboardingCompleted
    tenantProfile {
      id
      fullName
      location
      shortBio
      createdAt
      updatedAt
    }
  }
}
```

**Response (Landlord):**

```json
{
  "data": {
    "currentUser": {
      "id": "1",
      "email": "landlord@example.com",
      "type": "Landlord",
      "approvalStatus": "approved",
      "onboardingCompleted": true,
      "landlordProfile": {
        "id": "1",
        "fullName": "Chukwudi Okafor",
        "location": "Lagos, Nigeria",
        "shortBio": "Property developer with 10+ years experience",
        "phoneNumber": "+2348012345678",
        "isNinVerified": true,
        "isCertified": true,
        "isTopLandlord": false
      }
    }
  }
}
```

> **Note:** `landlordProfile` will be `null` for Tenant users, and `tenantProfile` will be `null` for Landlord users.

---

### Listings (Search)

Search and filter available published listings with pagination.

**Authentication Required:** No (public query)

**Query:**

```graphql
query SearchListings {
  listings(
    city: "Lagos"
    priceMin: 500000
    priceMax: 2000000
    propertyType: "flat"
    page: 1
    perPage: 20
  ) {
    id
    title
    description
    price
    address
    city
    propertyType
    bedrooms
    bathrooms
    isAvailable
    latitude
    longitude
    status
    photos
    document
    createdAt
    landlord {
      id
      email
    }
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `city` | String | No | Filter by city (case-insensitive) |
| `priceMin` | Float | No | Minimum price filter |
| `priceMax` | Float | No | Maximum price filter |
| `propertyType` | String | No | Filter by property type (`flat`, `duplex`, `bungalow`, `self_contain`, `room_and_parlour`) |
| `page` | Integer | No | Page number (default: 1) |
| `perPage` | Integer | No | Results per page (default: 20) |

> **Note:** Only returns listings where `isAvailable: true` and `status: "published"`.

**Response:**

```json
{
  "data": {
    "listings": [
      {
        "id": "1",
        "title": "Spacious 3 Bedroom Flat in Lekki",
        "price": 1500000.0,
        "city": "Lagos",
        "propertyType": "flat",
        "bedrooms": 3,
        "bathrooms": 2,
        "isAvailable": true,
        "photos": [
          "/rails/active_storage/blobs/redirect/abc123/photo1.jpg",
          "/rails/active_storage/blobs/redirect/def456/photo2.jpg"
        ],
        "document": null,
        "landlord": {
          "id": "1",
          "email": "landlord@example.com"
        }
      }
    ]
  }
}
```

---

### Single Listing

Get full details of a single listing.

**Authentication Required:** No (public query)

**Query:**

```graphql
query GetListing {
  listing(id: "1") {
    id
    title
    description
    price
    address
    city
    propertyType
    bedrooms
    bathrooms
    isAvailable
    latitude
    longitude
    status
    photos
    document
    createdAt
    updatedAt
    landlord {
      id
      email
      type
    }
  }
}
```

---

### Conversations

Get all conversations for the current user, ordered by most recent message.

**Authentication Required:** Yes

**Query:**

```graphql
query GetConversations {
  conversations {
    id
    tenantId
    landlordId
    listingId
    lastMessageAt
    createdAt
    tenant {
      id
      email
    }
    landlord {
      id
      email
    }
    listing {
      id
      title
      price
    }
    messages {
      id
      body
      senderId
      senderType
      readAt
      createdAt
    }
  }
}
```

---

### Messages

Get paginated message history for a conversation. Automatically marks unread messages as read.

**Authentication Required:** Yes (must be a participant in the conversation)

**Query:**

```graphql
query GetMessages {
  messages(conversationId: "1", page: 1) {
    id
    body
    senderId
    senderType
    readAt
    createdAt
  }
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `conversationId` | ID | Yes | Conversation to fetch messages from |
| `page` | Integer | No | Page number (default: 1, 50 messages per page) |

> **Note:** Fetching messages automatically marks all unread messages from the other party as read.

---

### Available Inspection Slots

Get available (unbooked, future) inspection slots for a listing.

**Authentication Required:** No

**Query:**

```graphql
query GetAvailableSlots {
  availableSlots(listingId: "1") {
    id
    startsAt
    endsAt
    isBooked
    listing {
      id
      title
    }
  }
}
```

> **Note:** Only returns slots where `isBooked: false` and `startsAt` is in the future, ordered by start time ascending.

---

### Pending Approvals (Admin)

Get all users awaiting admin review.

**Authentication Required:** Yes (Admin only)

**Query:**

```graphql
query PendingApprovals {
  pendingApprovals {
    id
    email
    type
    approvalStatus
    onboardingCompleted
    createdAt
    landlordProfile {
      id
      fullName
      location
    }
    tenantProfile {
      id
      fullName
    }
  }
}
```

> **Note:** Returns users with `approval_status` of `pending` or `submitted`, ordered by creation date.

---

### Platform Stats (Admin)

Get platform-wide statistics for the admin dashboard.

**Authentication Required:** Yes (Admin only)

**Query:**

```graphql
query PlatformStats {
  platformStats {
    totalUsers
    totalLandlords
    totalTenants
    totalListings
    activeListings
    totalCommissionPaid
    monthlyRevenue
  }
}
```

**Response:**

```json
{
  "data": {
    "platformStats": {
      "totalUsers": 1250,
      "totalLandlords": 350,
      "totalTenants": 890,
      "totalListings": 520,
      "activeListings": 380,
      "totalCommissionPaid": 5400000.0,
      "monthlyRevenue": 850000.0
    }
  }
}
```

---

### Flagged Listings (Admin)

Get all unresolved flagged listings (fraud reports).

**Authentication Required:** Yes (Admin only)

**Query:**

```graphql
query FlaggedListings {
  flaggedListings {
    id
    reason
    resolved
    createdAt
    listing {
      id
      title
      city
      price
      landlord {
        id
        email
      }
    }
    reporter {
      id
      email
      type
    }
  }
}
```

---

## Subscriptions

Subscriptions use WebSocket connections via Action Cable. Connect to `ws://localhost:3000/cable`.

### Message Received

Subscribe to new messages in a conversation. Fires when any participant sends a message.

```graphql
subscription OnMessageReceived {
  messageReceived(conversationId: "1") {
    id
    body
    senderId
    senderType
    readAt
    createdAt
  }
}
```

---

### Inspection Status Changed

Subscribe to inspection booking status changes. Fires when a booking is confirmed, cancelled, or completed.

```graphql
subscription OnInspectionStatusChanged {
  inspectionStatusChanged(bookingId: "1") {
    id
    status
    confirmedAt
    cancelledBy
    cancellationReason
  }
}
```

---

## Landlord Trust Badges

Landlord profiles display three trust badges, visible on the `LandlordProfile` type:

| Badge | Field | How It's Earned |
|---|---|---|
| **Verified** | `isNinVerified` | Admin calls `verifyLandlordNin` — NIN check via Prembly/YouVerify |
| **Certified** | `isCertified` | Admin calls `certifyLandlord` after reviewing property ownership documents |
| **Top Landlord** | `isTopLandlord` | Automatically calculated nightly: requires 3+ completed deals and 4.5+ average rating |

---

## Error Handling

All mutations return an `errors` field (array of strings). On success, `errors` is empty. On validation failure, it contains human-readable error messages.

**Validation Error Example:**

```json
{
  "data": {
    "createListing": {
      "listing": null,
      "errors": ["Title can't be blank", "Price must be greater than 0"]
    }
  }
}
```

**Authentication Error Example:**

```json
{
  "errors": [
    {
      "message": "createListing field requires authentication",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["createListing"]
    }
  ],
  "data": {}
}
```

**Authorization Error Example:**

```json
{
  "errors": [
    {
      "message": "Not authorized",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["createListing"]
    }
  ],
  "data": {}
}
```

---

## Enums Reference

### UserTypeEnumType

| Value | Maps To |
|---|---|
| `LANDLORD` | `"Landlord"` |
| `TENANT` | `"Tenant"` |
| `ADMIN` | `"Admin"` |

### PropertyTypeEnumType

| Value | Maps To |
|---|---|
| `FLAT` | `"flat"` |
| `DUPLEX` | `"duplex"` |
| `BUNGALOW` | `"bungalow"` |
| `SELF_CONTAIN` | `"self_contain"` |
| `ROOM_AND_PARLOUR` | `"room_and_parlour"` |

### ListingStatusEnumType

| Value | Maps To |
|---|---|
| `DRAFT` | `"draft"` |
| `PUBLISHED` | `"published"` |
| `RENTED` | `"rented"` |
| `REMOVED` | `"removed"` |

### InspectionStatusEnumType

| Value | Maps To |
|---|---|
| `PENDING` | `"pending"` |
| `CONFIRMED` | `"confirmed"` |
| `CANCELLED` | `"cancelled"` |
| `COMPLETED` | `"completed"` |

### PaymentStatusEnumType

| Value | Maps To |
|---|---|
| `PENDING` | `"pending"` |
| `PAID` | `"paid"` |
| `FAILED` | `"failed"` |
| `REFUNDED` | `"refunded"` |

---

*FindAm API Documentation — Generated March 2026*
