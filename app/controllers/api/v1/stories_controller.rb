class Api::V1::StoriesController < ApplicationController
    before_action :current_user, except: [:show]
    before_action :set_story, only: [:destroy, :toggle_favourite]

    # GET /api/v1/stories
    def index
      stories = []
      @current_user.university.faculties.each do |faculty|
        latest_story = faculty.stories.last
        next if latest_story.nil?
          stories << latest_story.as_json(
            except: [:user_id, :favourites, :faculty_id, :body, :creation_date, :created_at, :updated_at],
            include: {
              faculty: { only: [:id, :faculty_name] },
              user: {
                except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
                include: {
                  university: { only: [:id, :name, :simple_name] },
                  faculty: { only: [:id, :faculty_name] },
                  study: { only: [:id, :study_name] },
                }
              }
            }
          )
      end
      render json: stories.to_json
    end
    
      
    # GET /api/v1/stories/:faculty_id
    def show
      faculty = Faculty.find(params[:id])

      stories = faculty.stories.includes(user: [:university, :faculty]).map do |story|
        user = story.user.as_json(
          except: [:meet_status, :sex_to_meet, :university_to_meet_id, :creation_date, :created_at, :updated_at],
          include: {
            university: { only: [:id, :name, :simple_name] },
            faculty: { only: [:id, :faculty_name] },
            study: { only: [:id, :study_name] }
          })

        {
          id: story.id,
          user: user,
          faculty: faculty.as_json(only: [:id, :faculty_name]),
          body: story.body,
          background_gradient_index: story.background_gradient_index,
          creation_date: story.creation_date,
          favourite: story.favourites.exists?(user_id: current_user.id),
          already_conversation: current_user.initiated_conversations.exists?(user2_id: story.user.id) || current_user.received_conversations.exists?(user1_id: story.user.id),
          own_story: current_user.uid == story.user.uid
        }
      end
      render json: stories
    end
  
    # POST /api/v1/stories
    def create
      # Check if user has created more than 2 stories in the last 24 hours
      if current_user.stories.where('created_at >= ?', 24.hours.ago).count >= 2
        render json: { error: 'You have reached the daily limit of story creation' }, status: :unprocessable_entity
        return
      end

      @story = Story.new(create_story_params)
      @story.faculty = current_user.faculty
      @story.user = current_user

      if @story.save
        json = @story.as_json(
          include: {
            user: {
              except: [:created_at, :updated_at],
              include: {
                university: { only: [:id, :name, :simple_name] },
                faculty: { only: [:id, :faculty_name] },
                study: { only: [:id, :study_name] }
              }
            },
            faculty: {
              except: [:updated_at, :favourites]
            }
          }
        )
        json['favourite'] = false
        json['own_story'] = true
        json['already_conversation'] = false
        render json: json, status: :created
      else
        render json: @story.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/stories/:id
    def destroy
      @story.destroy
    end
  
    # PUT /api/v1/stories/:id/toggle_favourite
    def toggle_favourite
      favourite = @story.favourites.find_by(user_id: current_user.id)
      if favourite
        favourite.destroy
        render json: { favourite: @story.favourites.exists?(user_id: current_user.id) }
      else
        @story.favourites.create(user_id: current_user.id)
        render json: { favourite: @story.favourites.exists?(user_id: current_user.id) }
      end
    end
  
    private

    def set_story
      @story = Story.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def create_story_params
      params.require(:story).permit(:body, :background_gradient_index, :creation_date)
    end
end
  