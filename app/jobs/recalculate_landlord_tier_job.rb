class RecalculateLandlordTierJob < ApplicationJob
  queue_as :default

  def perform
    LandlordProfile.find_each do |profile|
      landlord = profile.landlord || profile.user

      deals_count = CommissionPayment.where(landlord_id: landlord.id, status: "paid").count
      # TODO: Average rating calculation once reviews are implemented
      average_rating = 5.0

      is_top = deals_count >= 3 && average_rating >= 4.5

      profile.update!(
        top_landlord: is_top,
        top_landlord_recalculated_at: Time.current
      )
    end
  end
end
