class Api::V1::UsersController < ApplicationController
    before_action :current_user, except: [:create, :show, :update]

    # GET /api/v1/users
    def index
        render json: current_user.as_json(
          except: [:created_at, :updated_at],
          include: {
            university: { only: [:id, :name, :simple_name] },
            faculty: { only: [:id, :faculty_name] },
            study: { only: [:id, :name, :courses] },
            university_to_meet: { only: [:id, :name, :simple_name] },
            faculties_to_meet: { only: [:id, :faculty_name], include: { studies: { only: [:id, :name, :courses] } } }
          }
        )
    end

    # GET /api/v1/users/hR1NbH4yhsMZJ9aZJuzqErzBwPJ3
    def show
        user = User.find_by(uid: params[:id])
        render json: user.as_json(
          except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
          include: {
            university: { only: [:id, :name, :simple_name] },
            faculty: { only: [:id, :faculty_name] },
            study: { only: [:id, :name, :courses] },
          }
        )
    end

    # POST /api/v1/users
    def create
        @user = User.new(create_user_params)

        # Find a University object with the given university_params
        @user.university = University.find_by(university_params)
      
        # Find a Faculty object with the given faculty_params
        @user.faculty = Faculty.find_by(faculty_params)
      
        # Find a Study object with the given study_params
        @user.study = Study.find_by(study_params)

        # Find a University object with the given university_to_meet_params
        university_to_meet_params = params[:university_to_meet]
        @user.university_to_meet = University.find_by(university_to_meet_params.permit(:name, :simple_name))
      
        # Loop through each faculty in the faculties_to_meet_params array
        faculties_to_meet_params = params[:faculties_to_meet]
        faculties_to_meet_params.each do |faculty_params|
          # Find a Faculty object with the given name
          faculty = Faculty.find_by(faculty_params.permit(:faculty_name))
          # Loop through each study in the current faculty and add it to the database
          faculty_params[:studies].each do |study_params|
            study = Study.find_by(study_params.permit(:name, :courses))
            faculty.studies << study
          end
          # Add the current faculty to the faculties_to_meet array
          @user.faculties_to_meet << faculty
        end

        if @user.save
            render json: @user.as_json(
              except: [:created_at, :updated_at],
              include: {
                university: { only: [:id, :name, :simple_name] },
                faculty: { only: [:id, :faculty_name] },
                study: { only: [:id, :name, :courses] },
                university_to_meet: { only: [:id, :name, :simple_name] },
                faculties_to_meet: { only: [:id, :faculty_name], include: { studies: { only: [:id, :name, :courses] } } }
              }),
            status: :created
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /users/hR1NbH4yhsMZJ9aZJuzqErzBwPJ3
    def update
        @user = User.find_by(uid: params[:id])
      
        # University too meet params
        university_to_meet_params = params[:university_to_meet]
        @user.university_to_meet = University.find_by(university_to_meet_params.permit(:name, :simple_name))
      
        # Loop through each faculty in the faculties_to_meet_params array
        faculties_to_meet_params = params[:faculties_to_meet]
        existing_faculties_to_meet = @user.faculties_to_meet.select do |faculty|
          faculties_to_meet_params.any? { |faculty_params| faculty.faculty_name == faculty_params[:faculty_name] }
        end
      
        # Loop through each faculty in the faculties_to_meet_params array
        faculties_to_meet_params.each do |faculty_params|
          # Find or create a Faculty object with the given name
          faculty = Faculty.find_by(faculty_params.permit(:faculty_name))
      
          # Loop through each study in the current faculty and add it to the database
          faculty_params[:studies].each do |study_params|
            study = Study.find_by(study_params.permit(:name, :courses))
            faculty.studies << study
          end
      
          # Add the current faculty to the faculties_to_meet array
          unless existing_faculties_to_meet.any? { |existing_faculty| existing_faculty.faculty_name == faculty.faculty_name }
            @user.faculties_to_meet << faculty
          end
        end
      
        # Remove faculties that are not in the faculties_to_meet_params array anymore
        @user.faculties_to_meet -= existing_faculties_to_meet.select do |existing_faculty|
          faculties_to_meet_params.none? { |faculty_params| existing_faculty.faculty_name == faculty_params[:faculty_name] }
        end
      
        if @user.update(cloud_token: params[:cloud_token], profile_image: params[:profile_image], meet_picture: params[:meet_picture], meet_status: params[:meet_status], sex_to_meet: params[:sex_to_meet], university_to_meet: @user.university_to_meet, faculties_to_meet: @user.faculties_to_meet)
          render json: @user.as_json(except: [:created_at, :updated_at]), status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
    end

    # DELETE /users/1
    def destroy
        @current_user.destroy
    end

    private
        # Only allow a list of trusted parameters through.
        def create_user_params
            params.require(:user).permit(:uid, :cloud_token, :name, :sex, :age, :profile_image, :meet_picture, :meet_status, :sex_to_meet)
        end

        def university_params
            params.require(:university).permit(:name, :simple_name)
        end
          
        def faculty_params
            params.require(:faculty).permit(:faculty_name)
        end
        
        def study_params
            params.require(:study).permit(:name, :courses)
        end
end