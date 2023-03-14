class Api::V1::MessagesController < ApplicationController
    before_action :current_user, only: [:create]

    # POST api/v1/conversations/:conversation_id/messages
    def create
      conversation = current_user.conversations.find_by(id: params[:conversation_id])
      @message = conversation.messages.build(message: params[:message], user: current_user, creation_date: params[:creation_date])

      if @message.save
        ConversationBroadcastJob.perform_later(@message.conversation)
        render json: @message, status: :created
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
    end
end
  