class Api::V1::StoriesController < ApplicationController
    before_action :current_user, except: [:show]
  
    # GET /api/v1/stories
    def index
      stories = []
      @user.university.faculties.each do |faculty|
      stories << faculty.stories.last.as_json(
            except: [:user_id, :favourites, :faculty_id, :background_gradient_index, :body, :created_at, :updated_at],
            include: {
              faculty: { only: [:id, :faculty_name] },
              user: {
                except: [:university_id, :faculty_id, :study_id, :meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
                include: {
                  university: { only: [:id, :name, :simple_name] },
                  faculty: { only: [:id, :faculty_name] },
                  study: { only: [:id, :name, :courses] },
                }
              }
            }
          )
      end
      render json: stories.compact
    end
    
      
    # GET /api/v1/stories/faculty_id
    def show
      faculty = Faculty.find(params[:id])

      stories = faculty.stories.includes(user: [:university, :faculty]).map do |story|
        user = story.user.as_json(
          except: [:university_id, :faculty_id, :study_id, :meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
          include: {
            university: { only: [:id, :name, :simple_name] },
            faculty: { only: [:id, :faculty_name] },
            study: { only: [:id, :name, :courses] }
          })

        {
          id: story.id,
          user: user,
          faculty: faculty,
          body: story.body,
          background_gradient_index: story.background_gradient_index,
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
        json = @story.as_json(include: [:user, :faculty], except: [:updated_at, :user_id, :faculty_id, :favourites])
        json['favourite'] = false
        json['own_story'] = true
        json['already_conversation'] = false
        render json: json, status: :created
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

    def create_story_params
    # Only allow a list of trusted parameters through.
      params.require(:story).permit(:body, :background_gradient_index)
    end
end
  