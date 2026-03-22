class Conversation < ApplicationRecord
  belongs_to :tenant, class_name: "User", foreign_key: :tenant_id
  belongs_to :landlord, class_name: "User", foreign_key: :landlord_id
  belongs_to :listing

  has_many :messages, dependent: :destroy

  validates :tenant_id, uniqueness: { scope: [ :landlord_id, :listing_id ] }

  scope :for_user, ->(user) {
    where(tenant_id: user.id).or(where(landlord_id: user.id))
  }
  scope :ordered, -> { order(last_message_at: :desc) }
end
