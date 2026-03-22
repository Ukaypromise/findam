class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, polymorphic: true

  validates :body, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :ordered, -> { order(created_at: :asc) }

  after_create :update_conversation_last_message_at

  private

  def update_conversation_last_message_at
    conversation.update!(last_message_at: created_at)
  end
end
