require 'googleauth'
require 'google/apis/fcm_v1'

class FirebaseCloudMessaging
  def initialize()
    # Initialize the API client with the service account credentials
    @fcm = Google::Apis::FcmV1::FirebaseCloudMessagingService.new
    @fcm.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open("./assets/firebase/#{ENV['ADMIN_FILE_NAME']}"),
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    )

  end

  def send_push_notification(cloud_token, title, body, type, data)
    message = Google::Apis::FcmV1::SendMessageRequest.new(
      message: {
        token: cloud_token,
        notification: {
          title: title,
          body: body,
        },
        android: {
          priority: "high"
        },
        data: {
          "type": type
        }.merge(data)
      }
    )
    response = @fcm.send_message("projects/#{ENV['PROJECT_ID']}", message) do |result, err|
      unless err.nil?
        p err
      end
    end
  end
end
