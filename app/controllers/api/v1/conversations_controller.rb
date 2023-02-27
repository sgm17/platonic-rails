class Api::V1::ConversationsController < ApplicationController
    before_action :current_user
  
    # GET /conversations
    def index
      conversations = current_user.conversations.includes(:messages, :user1, :user2).map do |conversation|
        other_user = conversation.user1_id == current_user.id ? conversation.user2 : conversation.user1
        last_message = conversation.messages.last
        {
          id: conversation.id,
          user: other_user.other_app_user,
          messages: [last_message.as_json(
            except: [:conversation_id, :updated_at]
          )]
        }
      end
      render json: conversations
    end

    # GET /conversations/conversation_id
    def show
      messages = Conversation.find(params[:id]).messages.map do |message|
        message.as_json(
          except: [:conversation_id, :updated_at]
        )
      end

      render json: messages
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