require_relative '../fcm/firebase_cloud_messaging'

class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, body, type, data)
    # Retrieve the user's cloud token from the database
    user = User.find(user_id)
    cloud_token = user.cloud_token

    # Send the push notification
    fcm = FirebaseCloudMessaging.new
    fcm.send_push_notification(cloud_token, title, body, type, data)
  end
end
