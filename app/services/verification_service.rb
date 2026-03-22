class VerificationService
  def initialize(landlord)
    @landlord = landlord
    @profile = landlord.landlord_profile || landlord.profile
  end

  def verify_nin(nin_number)
    # TODO: Make actual API call to Prembly/YouVerify
    # Prembly API:
    #   POST https://api.prembly.com/identitypass/verification/nin
    #   Headers: { "x-api-key" => ENV['PREMBLY_API_KEY'], "app-id" => ENV['PREMBLY_APP_ID'] }
    #   Body: { number: nin_number }
    #
    # YouVerify API:
    #   POST https://api.youverify.co/v2/api/identity/ng/nin
    #   Headers: { "token" => ENV['YOUVERIFY_API_KEY'] }
    #   Body: { id: nin_number, isSubjectConsent: true }

    result = { verified: true, message: "NIN verified successfully" }

    if result[:verified]
      @profile.update!(
        nin_verified: true,
        nin_verified_at: Time.current
      )
    end

    result
  end
end
