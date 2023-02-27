class Api::V1::MeetsController < ApplicationController
    before_action :current_user, only: [:index]
  
    # GET /api/v1/meets
    def index
      # Retrieve all meets that involve the current user
      meets = current_user.meets.includes(:user1, :user2)
    
      meets = meets.map do |meet|
        meet = {
          id: meet.id,
          user: meet.user1 == current_user ? meet.user2.other_app_user : meet.user1.other_app_user
        }
      end      

      render json: meets
    end
    
  
    # GET /api/v1/meets/1
    # def show
    #  render json: @meet
    # end
  
    # POST /api/v1/meets
    # def create
    #   @meet = Meet.new(meet_params)
    #   @meet.user = current_user
    #
    #   if @meet.save
    #     render json: @meet, status: :created, location: api_v1_meet_url(@meet)
    #   else
    #     render json: @meet.errors, status: :unprocessable_entity
    #   end
    # end
  
    # PATCH/PUT /api/v1/meets/1
    # def update
    #   if @meet.update(meet_params)
    #     render json: @meet
    #   else
    #     render json: @meet.errors, status: :unprocessable_entity
    #   end
    # end
  
    # DELETE /api/v1/meets/1
    # def destroy
    #   @meet.destroy
    # end
  
    def create_meetings
      users = User.where(meet_status: true)

      # Separate male and female users
      males = users.where(sex: 0)
      females = users.where(sex: 1)

      # Define a function to match users
      def match_users(user, users_to_match)
        # Sort users_to_match by faculty, to prioritize matches on the same faculty
        users_to_match = users_to_match.order(faculty_id: :desc)

        # Exclude users that have already been matched
        users_to_match = users_to_match.where.not(id: user.meets.pluck(:user2_id))

        # Check if any user in users_to_match matches all preferences
        perfect_matches = users_to_match.where(
          university_id: user.university_to_meet_id,
          sex: user.sex_to_meet,
          faculty_id: user.faculties_to_meet
        )

        if perfect_matches.any?
          # Return the first perfect match
          return perfect_matches.first
        end

        # Check if any user in users_to_match matches only university and sex preferences
        basic_matches = users_to_match.where(
          university_id: user.university_to_meet_id,
          sex: user.sex_to_meet
        )

        if basic_matches.any?
          # Return the first basic match
          return basic_matches.first
        end

        # Check if any user in users_to_match matches only sex preference
        sex_matches = users_to_match.where(sex: user.sex_to_meet)

        if sex_matches.any?
          # Return the first sex match
          return sex_matches.first
        end

        # No match found
        return nil
      end

      # Iterate over female users and match them with male users
      female_matches = {}

      females.each do |female|
        # Find male users that match female's preferences
        matching_males = males.where(
          university_id: female.university_to_meet_id,
          sex_to_meet: female.sex
        )
      
        # Match female with first available male
        match = match_users(female, matching_males)
      
        if match
          # Add match to female_matches hash
          female_matches[female.id] = match.id

          # Remove matched male from males array
          males = males.where.not(id: match.id)

          # Create Meet record
          Meet.create(user1: female, user2: match)
        end
      end

      # Iterate over male users that were not matched with females
      male_matches = {}

      males.each do |male|
        # Find female users that match male's preferences
        matching_females = females.where(
          university_id: male.university_to_meet_id,
          sex_to_meet: male.sex
        )
      
        # Match male with first available female
        match = match_users(male, matching_females)
      
        if match
          # Add match to male_matches hash
          male_matches[male.id] = match.id

          Meet.create(user1: male, user2: match)
        end
      end
    end

    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_meet
      @meet = current_user.meets.find(params[:id])
    end
  
    # Only allow a trusted parameter "white list" through.
    def meet_params
      params.require(:meet).permit(:user_id, :location, :time, :description)
    end
  end
  