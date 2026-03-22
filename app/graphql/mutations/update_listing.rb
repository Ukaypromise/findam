module Mutations
  class UpdateListing < BaseMutation
    description "Update an existing property listing (owner only)"

    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :price, Float, required: false
    argument :address, String, required: false
    argument :city, String, required: false
    argument :property_type, Types::Enums::PropertyTypeEnumType, required: false
    argument :bedrooms, Integer, required: false
    argument :bathrooms, Integer, required: false
    argument :latitude, Float, required: false
    argument :longitude, Float, required: false
    argument :status, Types::Enums::ListingStatusEnumType, required: false
    argument :photos, [ApolloUploadServer::Upload], required: false
    argument :document, ApolloUploadServer::Upload, required: false

    field :listing, Types::Objects::ListingType, null: true
    field :errors, [String], null: false

    def resolve(id:, **args)
      current_user = context[:current_resource]
      raise GraphQL::ExecutionError, "Not authorized" unless current_user

      listing = Listing.find(id)
      raise GraphQL::ExecutionError, "Not authorized" unless listing.landlord_id == current_user.id

      photos = args.delete(:photos)
      document = args.delete(:document)

      ActiveRecord::Base.transaction do
        listing.update!(args.compact)
        listing.photos.attach(photos) if photos.present?
        listing.document.attach(document) if document.present?
      end

      { listing: listing.reload, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { listing: nil, errors: e.record.errors.full_messages }
    end
  end
end
