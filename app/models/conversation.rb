class Conversation < ApplicationRecord
  belongs_to :user1, class_name: 'User', foreign_key: 'user1_id'
  belongs_to :user2, class_name: 'User', foreign_key: 'user2_id'
  has_many :messages, dependent: :destroy

  validates :user1, :user2, presence: true
  
  after_create_commit { ConversationBroadcastJob.perform_later(self) }
end
