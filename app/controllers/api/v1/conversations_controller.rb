class Api::V1::ConversationsController < ApplicationController
    before_action :current_user
  
    # GET /conversations
    def index
      initiated_conversations = current_user.initiated_conversations.includes(:messages, :user).map do |conversation|
        {
          id: conversation.id,
          user: conversation.user,
          messages: conversation.messages
        }
      end

      received_conversations = current_user.received_conversations.includes(:messages, :user).map do |conversation|
        {
          id: conversation.id,
          user: conversation.user,
          messages: conversation.messages
        }
      end
  
      render json: initiated_conversations.concat(received_conversations).sort_by { |hash| hash[:id] }
    end
  
    # POST /conversations
    def create
      conversation = current_user.initiated_conversations.build(user1_id: current_user.id, user2_id: params[:user_id])

      if conversation.save
        render json: conversation, status: :created
      else
        render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # def destroy
    #   conversation = current_user.conversations.find(params[:id])
    #   conversation.destroy
    #   head :no_content
    # end
  
    private
  
    # def conversation_params
    #   params.require(:initiated_conversations).permit(:user_id)
    # end
end  