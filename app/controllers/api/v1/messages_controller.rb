class Api::V1::MessagesController < ApplicationController
    before_action :current_user, only: [:create]
  
    # POST /conversations/1/messages
    def create
      conversation = current_user.conversations.find_by(id: params[:conversation_id])
      @message = conversation.messages.build(message: params[:message], user: current_user)
  
      if @message.save
        ConversationBroadcastJob.perform_later(@message.conversation)
        render json: @message, status: :created
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
    end
end
  