You are building out the FindAm backend — a Rails 8.0 / GraphQL / PostgreSQL property rental platform. The architecture guide is reproduced below. Read it fully before writing any code.

Your task is to implement ALL planned development areas in Section 4, plus the file attachments requirement. Follow every convention in Section 5 exactly. Never create REST endpoints (except webhooks). Never bypass auth middleware. Never create profiles manually.

---

## ARCHITECTURE SUMMARY (read carefully)

- Rails 8.0, Ruby 3.4, graphql-ruby, Devise + GraphQL Devise ~2.1
- Pure GraphQL API — single endpoint POST /graphql
- STI user model: Landlord / Tenant / Admin (type column — never touch it)
- All mutations extend Mutations::BaseMutation
- Current user: context[:current_resource]
- Profiles auto-created via after_create callback — never create manually
- Approval workflow: pending → submitted → approved / rejected
- Real-time via Action Cable + Solid Cable (no Redis)
- Background jobs via Solid Queue
- Payments: Paystack (primary) + Flutterwave
- File storage: AWS S3 + Active Storage (+ optional Cloudinary)
- Identity verification: Prembly / YouVerify

---

## WHAT TO BUILD

### 1. Property Listings (app/models/listing.rb + GraphQL)

Model fields:
- belongs_to :landlord (STI User, foreign_key: :landlord_id)
- title:string, description:text, price:decimal, address:string, city:string
- property_type:string (enum: flat, duplex, bungalow, self_contain, room_and_parlour)
- bedrooms:integer, bathrooms:integer
- is_available:boolean (default: true)
- latitude:decimal, longitude:decimal
- status:string (enum: draft, published, rented, removed) default: draft
- File attachments: use Active Storage `has_many_attached :photos` — a listing can have MANY photo attachments (images). Also `has_one_attached :document` for any supporting property document.

Validations:
- title, description, price, address, city, property_type are required
- price > 0
- Only landlords with approval_status == 'approved' can create listings

GraphQL types (app/graphql/types/objects/listing_type.rb):
- Expose all fields above
- photos field returns array of signed S3/blob URLs (use rails_blob_url or url_for)
- document field returns a single signed URL or nil

GraphQL additions:
- Query: listings(city: String, priceMin: Float, priceMax: Float, propertyType: String, page: Int, perPage: Int) — paginated, filter by available listings only
- Query: listing(id: ID!) — single listing with all details
- Mutation: createListing — landlord only, requires approved status, accepts photo uploads as [ApolloUpload] / multipart
- Mutation: updateListing — owner only
- Mutation: deleteListing — owner only, soft delete (set status to 'removed')
- Mutation: toggleListingAvailability — owner only, flips is_available

For file uploads, use the graphql-upload gem pattern: accept `uploads: [ApolloUpload]` as argument in createListing and updateListing mutations. Attach blobs inside resolve via `listing.photos.attach(uploads)`.

---

### 2. In-App Messaging

Models:
- Conversation: belongs_to :listing, has_many :messages. Unique per [tenant_id, landlord_id, listing_id]. Fields: tenant_id:integer, landlord_id:integer, listing_id:integer, last_message_at:datetime
- Message: belongs_to :conversation, belongs_to :sender (User polymorphic). Fields: body:text, read_at:datetime, sender_id:integer, sender_type:string

GraphQL:
- Query: conversations — current user's conversations, ordered by last_message_at desc
- Query: messages(conversationId: ID!, page: Int) — paginated message history, mark as read on fetch
- Mutation: sendMessage(recipientId: ID!, listingId: ID!, body: String!) — creates conversation if none exists, creates message, broadcasts via Action Cable, updates last_message_at
- Mutation: markMessagesRead(conversationId: ID!)
- Subscription: messageReceived(conversationId: ID!) — broadcasts new message to both parties

Phone number privacy: never expose phone_number field in tenant/landlord types unless both parties have an active conversation.

---

### 3. Inspection Booking

Models:
- InspectionSlot: belongs_to :landlord, belongs_to :listing. Fields: starts_at:datetime, ends_at:datetime, is_booked:boolean (default: false)
- InspectionBooking: belongs_to :tenant (User), belongs_to :landlord (User), belongs_to :listing, belongs_to :inspection_slot. Fields: status:string (enum: pending, confirmed, cancelled, completed), cancelled_by:string, cancellation_reason:string, confirmed_at:datetime

GraphQL:
- Query: availableSlots(listingId: ID!) — returns slots where is_booked: false and starts_at > now
- Mutation: createInspectionSlot(listingId: ID!, startsAt: ISO8601DateTime!, endsAt: ISO8601DateTime!) — landlord only
- Mutation: bookInspection(slotId: ID!, listingId: ID!) — tenant only, sets slot.is_booked = true, creates booking with status: pending
- Mutation: confirmInspection(bookingId: ID!) — landlord only, sets status: confirmed, confirmed_at: Time.current
- Mutation: cancelInspection(bookingId: ID!, reason: String) — either party, sets status: cancelled, records cancelled_by
- Subscription: inspectionStatusChanged(bookingId: ID!) — fires when booking status changes

---

### 4. Landlord Verification (Trust Badges)

Add to LandlordProfile:
- nin_verified:boolean default: false, nin_verified_at:datetime
- certified:boolean default: false, certified_at:datetime
- top_landlord:boolean default: false, top_landlord_recalculated_at:datetime

GraphQL mutations (admin only):
- verifyLandlordNin(landlordId: ID!) — calls Prembly/YouVerify stub service, sets nin_verified and nin_verified_at (stub the external call with a TODO comment — structure the service class properly)
- certifyLandlord(landlordId: ID!) — admin sets certified: true, certified_at
- Background job: RecalculateLandlordTierJob — checks deals count >= 3 and average rating >= 4.5, sets top_landlord accordingly. Schedule nightly via Solid Queue.

Expose badge fields on LandlordProfileType as:
- isNinVerified, isCertified, isTopLandlord

---

### 5. Commission & Payments

Model: CommissionPayment
- belongs_to :listing, belongs_to :tenant (User), belongs_to :landlord (User)
- Fields: amount:decimal, tenant_percentage:decimal, landlord_percentage:decimal
- status:string (enum: pending, paid, failed, refunded) default: pending
- paystack_reference:string, paid_at:datetime, payment_url:string

Service: app/services/payment_service.rb — wrap Paystack API (stub with TODO for actual HTTP call, but structure the class properly with initialize, create_payment_link, verify_payment methods)

GraphQL:
- Mutation: initiatePayment(listingId: ID!) — tenant only, creates CommissionPayment record, calls PaymentService to generate Paystack payment link, returns payment_url
- Mutation: confirmRentalAgreement(listingId: ID!) — both parties must call this. When both confirm: triggers payment initiation automatically. Track confirmations with landlord_confirmed_at and tenant_confirmed_at on CommissionPayment.

REST webhook (the ONE allowed REST endpoint — exempt from CSRF):
- POST /webhooks/paystack — verifies Paystack HMAC signature, updates CommissionPayment status, triggers Action Cable notification to both parties

---

### 6. Admin Dashboard

All queries/mutations here require current_user.admin? — raise 'Not authorized' otherwise.

GraphQL queries:
- pendingApprovals — returns users with approval_status: 'pending' or 'submitted', ordered by created_at
- platformStats — returns { totalUsers, totalLandlords, totalTenants, totalListings, activeListings, totalCommissionPaid, monthlyRevenue }
- flaggedListings — stub model FlaggedListing (belongs_to :listing, belongs_to :reporter (User), reason:string), query returns all unresolved flags

GraphQL mutations:
- approveUser(userId: ID!) — calls user.approve!, sends approval email via ActionMailer (stub mailer)
- rejectUser(userId: ID!, reason: String!) — calls user.reject!(reason:), sends rejection email
- suspendUser(userId: ID!, reason: String!) — sets approval_status: 'suspended', stores suspension_reason

---

## IMPLEMENTATION RULES

1. Every migration must have the correct indexes (foreign keys, status columns, frequently queried fields).
2. Every model must have appropriate validations and scopes (e.g., Listing.available, Listing.published).
3. Every mutation must follow the checklist in Section 5.4: BaseMutation → arguments → fields with errors → resolve → register in MutationType.
4. Every mutation that modifies data must be wrapped in ActiveRecord::Base.transaction where multiple records are touched.
5. GraphQL fields: use null: false for always-present fields, null: true for optional ones.
6. Error handling: rescue ActiveRecord::RecordInvalid and return { object: nil, errors: e.record.errors.full_messages }. Raise GraphQL::ExecutionError for auth errors.
7. RSpec tests: for each mutation write specs covering success case, validation failure, and auth failure. Use FactoryBot factories.
8. Naming: follow the table in Section 5.1 exactly. GraphQL mutations are VerbNoun PascalCase. DB tables are plural snake_case.
9. Do not add Redis. Use Solid Cable and Solid Queue only.
10. For Active Storage file uploads in GraphQL, add the graphql-multipart-request gem and follow its Rails integration pattern.

---

## DELIVERY ORDER

Work in this order to avoid dependency issues:
1. Migrations (all at once, in dependency order)
2. Models + validations + scopes
3. FactoryBot factories
4. GraphQL types (objects and enums)
5. Service classes (stubs with TODOs for external APIs)
6. Mutations (in order: listings → messages → inspections → payments → admin)
7. Queries
8. Subscriptions
9. Webhooks controller
10. Background jobs
11. RSpec tests
12. routes.rb updates (only add webhook route + ensure /graphql and /graphiql are present)

Start now. Ask no clarifying questions — use the architecture guide and these instructions as your complete specification.