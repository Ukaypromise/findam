module Types
  class Objects::ListingType < Types::BaseObject
    field :id, ID, null: false
    field :landlord_id, Integer, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :price, Float, null: false
    field :address, String, null: false
    field :city, String, null: false
    field :property_type, String, null: false
    field :bedrooms, Integer, null: true
    field :bathrooms, Integer, null: true
    field :is_available, Boolean, null: false
    field :latitude, Float, null: true
    field :longitude, Float, null: true
    field :status, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :landlord, Types::Objects::LandlordType, null: false

    field :photos, [ String ], null: false
    field :document, String, null: true

    def photos
      return [] unless object.photos.attached?

      object.photos.map do |photo|
        Rails.application.routes.url_helpers.rails_blob_url(photo, only_path: true)
      end
    end

    def document
      return nil unless object.document.attached?

      Rails.application.routes.url_helpers.rails_blob_url(object.document, only_path: true)
    end
  end
end
