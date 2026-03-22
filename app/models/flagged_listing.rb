class FlaggedListing < ApplicationRecord
  belongs_to :listing
  belongs_to :reporter, class_name: "User", foreign_key: :reporter_id

  validates :reason, presence: true

  scope :unresolved, -> { where(resolved: false) }
end
