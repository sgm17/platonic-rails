class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  validates :message, presence: true
end
