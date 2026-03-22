# frozen_string_literal: true

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  include GraphqlDevise::Authenticatable

  has_one :profile, dependent: :destroy

  after_create :create_profile

  state_machine :approval_status, initial: :pending do
    state :pending
    state :submitted
    state :approved
    state :rejected
    state :suspended

    event :submit_for_review do
      transition :pending => :submitted
    end

    event :approve do
      transition [:pending, :submitted, :rejected] => :approved
    end

    event :reject do
      transition [:pending, :submitted] => :rejected
    end

    event :suspend do
      transition [:approved, :submitted] => :suspended
    end

    event :resubmit do
      transition :rejected => :submitted
    end

    after_transition any => :approved do |user|
      user.update_columns(
        approved_at: Time.current,
        rejected_at: nil,
        rejection_reason: nil
      )
    end

    after_transition any => :rejected do |user|
      user.update_columns(
        rejected_at: Time.current,
        approved_at: nil
      )
    end
  end

  def landlord?
    is_a?(Landlord)
  end

  def tenant?
    is_a?(Tenant)
  end

  def admin?
    is_a?(Admin)
  end

  def approve!(reason: nil)
    fire_state_event(:approve)
  end

  def reject!(rejection_reason: nil)
    self.rejection_reason = rejection_reason
    fire_state_event(:reject)
  end

  def suspend!(reason:)
    self.suspension_reason = reason
    fire_state_event(:suspend)
  end

  private

  def fire_state_event(event)
    unless send("#{event}")
      raise ActiveRecord::RecordInvalid.new(self)
    end
    true
  end

  def create_profile
    return if admin?

    profile_type = landlord? ? "LandlordProfile" : "TenantProfile"
    Profile.create!(user: self, type: profile_type)
  end
end
