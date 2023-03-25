class ApplicationController < ActionController::API
    def current_user
        return unless request.env['firebase.user']
        @current_user ||= User.find_by(uid: request.env['firebase.user'][0]['user_id'])
    end

    def firebase_cloud_messaging
        service_account_key_path = Rails.root.join('app', 'assets', 'firebase', ENV['ADMIN_FILE_NAME'])

        @firebase_cloud_messaging = FirebaseCloudMessaging.new(
          service_account_key_path
        )
    end
end
