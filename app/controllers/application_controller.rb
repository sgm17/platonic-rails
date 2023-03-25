class ApplicationController < ActionController::API
    def current_user
        return unless request.env['firebase.user']
        @current_user ||= User.find_by(uid: request.env['firebase.user'][0]['user_id'])
    end

    def firebase_cloud_messaging
        service_account_key_path = Rails.root.join('app', 'assets', 'platonic-3bc9d-firebase-adminsdk-oihb8-5560f86132.json')

        @firebase_cloud_messaging = FirebaseCloudMessaging.new(
          "platonic-3bc9d",
          service_account_key_path
        )
      end
      
end
