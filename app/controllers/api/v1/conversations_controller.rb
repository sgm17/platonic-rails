class Api::V1::ConversationsController < ApplicationController
    before_action :current_user
  
    # GET /api/v1/conversations
    def index
      conversations = @current_user.conversations.map do |conversation|
        conversation.as_json(
          except: [:created_at, :updated_at],
          include: {
            user1: {},
            user2: {}
          }
        )
      end
      render json: conversations
    end

    # POST /api/v1/conversations
    # def create
    #   conversation = @current_user.initiated_conversations.build(user2_id: params[:user2_id])
    #   
    #   if conversation.save
    #     json = conversation.as_json(
    #       include: {
    #         user1: {},
    #         user2: {}
    #       }
    #     )
    #     ConversationBroadcastJob.perform_later(json)
    #     render json: json, status: :created
    #   else
    #     render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
    #   end
    # end

    # POST /api/v1/conversations/:conversation_id/create_message
    # def create_message
    #   conversation = current_user.conversations.find(params[:conversation_id])
    #   message = conversation.messages.build(body: params[:body], user_id: params[:user_id], creation_date: params[:creation_date])
    # 
    #   if message.save
    # 
    #     json = message.conversation.as_json(
    #       include: {
    #         user1: {},
    #         user2: {}
    #       }
    #     )
    # 
    #     ConversationBroadcastJob.perform_later(json)
    #     render json: message, status: :created
    #   else
    #     render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    #   end
    # end

    # DELETE /api/v1/conversations/:conversation_id
    def destroy
      conversation = Conversation.find(params[:id])
      
      if conversation.destroy
        render json: { destroyed: true }
      else
        render json: { destroyed: false }
      end
    end
end  