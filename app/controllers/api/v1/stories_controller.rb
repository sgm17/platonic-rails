class Api::V1::StoriesController < ApplicationController
    before_action :current_user, except: [:show]
  
    # GET /api/v1/stories
    def index
        stories = @user.university.stories.includes(:user, :faculty).map do |story|
            {
              app_user: story.user,
              faculty: story.faculty,
              body: story.body,
              background_gradient: story.background_gradient,
              created_at: story.created_at,
              favourite: story.favourites.exists?(user_id: current_user.id),
              already_conversation: current_user.conversations.exists?(user_id: story.user.id),
              own_story: current_user.uid == story.user.uid
            }
      render json: stories
    end
  
    # GET /api/v1/stories/1
    def show
    end
  
    # POST /api/v1/stories
    def create
      @story = Story.new(story_params)
  
      if @story.save
        render json: @story, status: :created
      else
        render json: @story.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /api/v1/stories/1
    def update
      if @story.update(story_params)
        render json: @story
      else
        render json: @story.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /api/v1/stories/1
    def destroy
      @story.destroy
    end
  
    # POST /api/v1/stories/1/toggle_favourite
    def toggle_favourite
      favourite = @story.favourites.find_or_initialize_by(user_id: current_user.id)
      if favourite.new_record?
        favourite.save
        render json: @story.as_json.merge(favourited: true)
      else
        favourite.destroy
        render json: @story.as_json.merge(favourited: false)
      end
    end
  
    private

    # Only allow a list of trusted parameters through.
    def story_params
      params.require(:story).permit(:user_id, :faculty_id, :body, :background_gradient)
    end
  end
end
  