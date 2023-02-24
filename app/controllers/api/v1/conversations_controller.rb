class Api::V1::ConversationsController < ApplicationController
    before_action :authenticate_request
  
    def index
      conversations = current_user.conversations.includes(:messages, :user).map do |conversation|
        {
          id: conversation.id,
          user: conversation.user,
          messages: conversation.messages
        }
      end
  
      render json: conversations
    end
  
    def create
      conversation = current_user.conversations.build(conversation_params)
  
      if conversation.save
        render json: conversation, status: :created
      else
        render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def destroy
      conversation = current_user.conversations.find(params[:id])
      conversation.destroy
      head :no_content
    end
  
    private
  
    def conversation_params
      params.require(:conversation).permit(:user_id)
    end
end  