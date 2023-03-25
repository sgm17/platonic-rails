class Api::V1::UsersController < ApplicationController
  before_action :current_user, except: [:create]

    # GET /api/v1/users
    def index
      faculties_to_meet = @current_user.faculties_to_meet.map do |faculty|
        faculty.as_json(only: [:id])
      end
      render json: @current_user.as_json(
        except: [:created_at, :updated_at],
        include: {
          university: { except: [:created_at, :updated_at] },
          faculty: { except: [:created_at, :updated_at] },
          study: { except: [:created_at, :updated_at] },
          university_to_meet: { except: [:created_at, :updated_at] },
          faculties_to_meet: { except: [:created_at, :updated_at] }
        }
      )
    end

    # POST /api/v1/users
    def create
        @user = User.new(create_user_params)
      
        # Loop through each faculty in the faculties_to_meet_params array
        faculties_to_meet_params = params[:faculties_to_meet]
        faculties_to_meet_params.each do |faculty_params|
          # Find a Faculty object with the given name
          faculty = Faculty.find(faculty_params[:id])

          # Add the current faculty to the faculties_to_meet array
          @user.faculties_to_meet << faculty
        end

        if @user.save
            render json: @user.as_json(
              except: [:created_at, :updated_at],
              include: {
                university: { except: [:created_at, :updated_at] },
                faculty: { except: [:created_at, :updated_at] },
                study: { except: [:created_at, :updated_at] },
                faculties_to_meet: { only: [:id] }
              }
            ),
            status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /api/v1/users/:id
    def update
      if @current_user.update(update_user_params)
        faculties_to_meet_params = params[:faculties_to_meet]
    
        # Get the list of faculties that are currently associated with the user
        current_faculties = @current_user.faculties_to_meet.to_a
    
        # Iterate over the faculties passed in the parameters
        faculties_to_meet_params.each do |faculty_params|
          faculty = Faculty.find(faculty_params[:id])
    
          # If the current user doesn't have the faculty, add it
          unless current_faculties.include?(faculty)
            @current_user.faculties_to_meet << faculty
          end
        end
    
        # Iterate over the faculties that the user currently has
        current_faculties.each do |faculty|
          # If the user has a faculty that isn't in the parameters, remove it
          unless faculties_to_meet_params.any? { |params| params[:id] == faculty.id }
            @current_user.faculties_to_meet.delete(faculty)
          end
        end

        render json: @current_user.as_json(
          except: [:created_at, :updated_at],
          include: {
            university: { except: [:created_at, :updated_at] },
            faculty: { except: [:created_at, :updated_at] },
            study: { except: [:created_at, :updated_at] },
            faculties_to_meet: { only: [:id] }
          }
        )
      else
        render json: @current_user.errors, status: :unprocessable_entity
      end
    end

    # PUT /api/v1/users/cloud_token
    def cloud_token
      if @current_user.update(params[:cloud_token])
        render json: { updated: true }
      else
        render json: { updated: false }
      end
    end

    # DELETE /users/1
    def destroy
        if @current_user.destroy
          render json: { destroyed: true }
        else
          render json: { destroyed: false }
        end
    end

    private
    
    # Only allow a list of trusted parameters through.
    def create_user_params
      params.require(:user).permit(:uid, :cloud_token, :name, :email, :sex, :age, :university_id, :faculty_id, :study_id, :meet_status, :sex_to_meet, :university_to_meet_id )
    end

    def update_user_params
      params.require(:user).permit(:profile_image, :meet_picture, :meet_status, :sex_to_meet, :university_to_meet_id)
    end
end