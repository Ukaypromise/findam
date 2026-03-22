module Mutations
  class CreateListing < BaseMutation
    description "Create a new property listing (landlord only, requires approved status)"

    argument :title, String, required: true
    argument :description, String, required: true
    argument :price, Float, required: true
    argument :address, String, required: true
    argument :city, String, required: true
    argument :property_type, Types::Enums::PropertyTypeEnumType, required: true
    argument :bedrooms, Integer, required: false
    argument :bathrooms, Integer, required: false
    argument :latitude, Float, required: false
    argument :longitude, Float, required: false
    argument :status, Types::Enums::ListingStatusEnumType, required: false
    argument :photos, [ ApolloUploadServer::Upload ], required: false
    argument :document, ApolloUploadServer::Upload, required: false

    field :listing, Types::Objects::ListingType, null: true
    field :errors, [ String ], null: false

    def resolve(**args)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user
      raise GraphQL::ExecutionError, "Only landlords can create listings" unless current_user.landlord?
      raise GraphQL::ExecutionError, "Landlord must be approved" unless current_user.approval_status == "approved"

      photos = args.delete(:photos)
      document = args.delete(:document)

      listing = current_user.listings.build(args)

      ActiveRecord::Base.transaction do
        listing.save!
        listing.photos.attach(photos) if photos.present?
        listing.document.attach(document) if document.present?
      end

      { listing: listing, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { listing: nil, errors: e.record.errors.full_messages }
    end
  end
end
