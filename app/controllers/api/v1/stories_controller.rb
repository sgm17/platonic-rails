class Api::V1::StoriesController < ApplicationController
    before_action :current_user, except: [:show]
  
    # GET /api/v1/stories
    def index
      stories = []
      @user.university.faculties.each do |faculty|
        stories.concat(faculty.stories)
      end
      render json: stories
    end
  
    # GET /api/v1/stories/faculty_id
    def show
      faculty = Faculty.find(params[:id])

      stories = []

      faculty.stories.includes(:user, :faculty).map do |story|
        stories << {
          app_user: story.user,
          faculty: story.faculty,
          body: story.body,
          background_gradient: story.background_gradient,
          created_at: story.created_at,
          favourite: story.favourites.exists?(user_id: current_user.id),
          already_conversation: current_user.initiated_conversations.exists?(user2_id: story.user.id) || current_user.received_conversations.exists?(user1_id: story.user.id),
          own_story: current_user.uid == story.user.uid
        }
      end
      render json: stories
    end
  
    # POST /api/v1/stories
    def create
      @story = Story.new(create_story_params)
      @story.user = current_user
      @story.faculty = current_user.faculty

      if @story.save
        render json: @story, status: :created
      else
        render json: @story.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /api/v1/stories/1
    # def update
    #   if @story.update(story_params)
    #     render json: @story
    #   else
    #     render json: @story.errors, status: :unprocessable_entity
    #   end
    # end
  
    # DELETE /api/v1/stories/1
    def destroy
      @story.destroy
    end
  
    # POST /api/v1/stories/1/toggle_favourite
    def toggle_favourite
      @story = Story.find(params[:id])
      favourite = @story.favourites.find_by(user_id: current_user.id)
      if favourite
        favourite.destroy
        render json: { message: 'Favourite removed' }
      else
        @story.favourites.create(user_id: current_user.id)
        render json: { message: 'Favourited!' }
      end
    end
  
    private

    # Only allow a list of trusted parameters through.
    def create_story_params
      params.require(:story).permit(:faculty, :body, :background_gradient)
    end
end
  