# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  include GraphqlDevise::Authenticatable

  has_one :profile, dependent: :destroy


  after_create :create_profile

  def landlord?
    is_a?(Landlord)
  end

  def tenant?
    is_a?(Tenant)
  end

  def admin?
    is_a?(Admin)
  end

  def approve!
    update!(
      approval_status: "approved",
      approved_at: Time.current,
      rejected_at: nil,
      rejection_reason: nil
    )
  end

  def reject!(rejection_reason: nil)
    update!(
      approval_status: "rejected",
      rejected_at: Time.current,
      rejection_reason: rejection_reason,
      approved_at: nil
    )
  end

  private

  def create_profile
    return if admin?

    profile_type = iec? ? "IecProfile" : "StudentProfile"
    Profile.create!(user: self, type: profile_type)
  end
end
