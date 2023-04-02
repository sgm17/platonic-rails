require_relative '../../../fcm/firebase_cloud_messaging'

class Api::V1::MeetsController < ApplicationController
    before_action :current_user, only: [:index]
  
    # GET /api/v1/meets
    def index
      # Retrieve all meets that involve the current user
      meets = @current_user.meets.includes(:user1, :user2)
    
      meets = meets.map do |meet|
        user = meet.user1 == @current_user ? meet.user2 : meet.user1
        meet = {
          id: meet.id,
          user: user.as_json(
            except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
            include: {
              university: {},
              faculty: {},
              study: {}
            }
          )
        }
      end
      render json: meets
    end

    # DELETE /api/v1/meets/:meet_id
    def destroy
      meet = Meet.find(params[:id])

      if meet.destroy
        render json: { destroyed: true }
      else
        render json: meet.errors, status: :unprocessable_entity
      end
    end

    def self.create_meetings
      users = User.where(meet_status: true)

      # Separate male and female users
      males = users.where(sex: 0)
      females = users.where(sex: 1)

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

          send_push_notification(female.id, match.name, "Nuevo meet", "meet", match.id.to_s)
          send_push_notification(match.id, female.name, "Nuevo meet", "meet", female.id.to_s)

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

          send_push_notification(male.id, match.name, "Nuevo meet", "meet", match.id.to_s)
          send_push_notification(match.id, male.name, "Nuevo meet", "meet", male.id.to_s)

          Meet.create(user1: male, user2: match)
        end
      end
    end

    private

    # Define a function to match users
    def self.match_users(user, users_to_match)
      # Sort users_to_match by faculty, to prioritize matches on the same faculty
      users_to_match = users_to_match.order(faculty_id: :desc)

      # Exclude users that have already been matched
      users_to_match = users_to_match.where.not(
        id: user.meets.select { |meet| 
          meet.user1_id == user.id && meet.user2_id == other_user.id ||
          meet.user1_id == other_user.id && meet.user2_id == user.id
        }.pluck(:user2_id)
      )

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

    def self.send_push_notification(user_id, title, body, type, id)
      # Retrieve the user's cloud token from the database
      user = User.find(user_id)
      cloud_token = user.cloud_token

      # Send the push notification
      fcm = FirebaseCloudMessaging.new
      fcm.send_push_notification(cloud_token, title, body, type, id)
    end
  end
  