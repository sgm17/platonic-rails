class Api::V1::MessagesController < ApplicationController
    before_action :authenticate_request
  
    def create
      conversation = current_user.conversations.find(params[:conversation_id])
      message = conversation.messages.build(message_params)
  
      if message.save
        render json: message, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def message_params
      params.require(:message).permit(:content)
    end
end
  