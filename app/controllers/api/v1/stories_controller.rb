class Api::V1::StoriesController < ApplicationController
    before_action :current_user
    before_action :set_story, only: [:destroy, :toggle_favourite, :visualizations]

    # GET /api/v1/stories
    def index
      stories = []
      @current_user.university.faculties.each do |faculty|
        latest_story = faculty.stories.where('created_at >= ?', 24.hours.ago).last
        next if latest_story.nil?
          stories << latest_story.as_json(
            except: [:user_id, :favourites, :faculty_id, :body, :creation_date, :created_at, :updated_at],
            include: {
              faculty: { except: [:created_at, :updated_at] },
              user: {
                except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at]
              }
            }
          )
      end
      render json: stories
    end
    
      
    # GET /api/v1/stories/:faculty_id
    def show
      faculty = Faculty.find(params[:id])
      stories = faculty.stories
                          .where('created_at >= ?', 24.hours.ago)
                          .includes(user: [:university, :faculty])
                          .map do |story|
        story_json = story.as_json(
          except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
          include: {
            user: {
              except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
            },
            faculty: {},
            visualizations: {
              except: [:created_at, :updated_at],
              include: {
                user: {
                  except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
                }
              }
            }
          }
        )

        story_json['favourite'] = story.favourites.exists?(user_id: @current_user.id)

        story_json
      end
      render json: stories
    end
  
    # POST /api/v1/stories
    def create
      # Check if user has created more than 2 stories in the last 24 hours
      if @current_user.stories.where('created_at >= ?', 24.hours.ago).count >= 2
        render json: { error: 'You have reached the daily limit of story creation' }, status: :too_many_requests
        return
      end

      @story = Story.new(create_story_params)
      @story.faculty = @current_user.faculty
      @story.user = @current_user

      if @story.save
        story_json = @story.as_json(
          include: {
            user: {
              except: [:created_at, :updated_at],
            },
            faculty: {
              except: [:updated_at, :favourites]
            }
          }
        )

        story_json['favourite'] = false

        render json: story_json, status: :created
      else
        render json: @story.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/stories/:id
    def destroy
      if @story.destroy
        render json: { destroyed: true }
      else
        render json: @story.errors, status: :unprocessable_entity
      end
    end
  
    # PUT /api/v1/stories/:id/toggle_favourite
    def toggle_favourite
      favourite = @story.favourites.find_by(user_id: @current_user.id)
      if favourite
        favourite.destroy
        render json: { favourite: @story.favourites.exists?(user_id: @current_user.id) }
      else
        @story.favourites.create(user_id: @current_user.id)

        data_json = {"faculty_id" => @story.faculty.id.to_s}

        PushNotificationJob.perform_later(@story.user.id, "A #{@current_user.name} le ha gustado tu historia", nil, "favourite", data_json)
        
        render json: { favourite: @story.favourites.exists?(user_id: @current_user.id) }
      end
    end

    # POST /api/v1/stories/:id/visualizations
    def visualizations
      visualization = @story.visualizations.find_or_initialize_by(user: @current_user)
      
      if visualization.new_record?
        if visualization.save
          render json: { visualization: true }, status: :created
        else
          render json: visualization.errors, status: :unprocessable_entity
        end
      else
        render json: { visualization: false }, status: :ok
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
  