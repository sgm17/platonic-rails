require 'googleauth'
require 'google/apis/fcm_v1'

class FirebaseCloudMessaging
  def initialize(project_id, service_account_key_path)
    # Initialize the Project id
    @project_id = project_id

    # Initialize the API client with the service account credentials
    @fcm = Google::Apis::FcmV1::FirebaseCloudMessagingService.new
    @fcm.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(service_account_key_path),
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    )
  end

  def send_push_notification(cloud_token, title, body, title_key, body_key)
    message = Google::Apis::FcmV1::SendMessageRequest.new(
      message: {
        token: cloud_token,
        notification: {
          title: title,
          body: body
        },
        android: {
          priority: "high"
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              alert: {
                title_loc_key: title_key,
                body_loc_key: body_key
              }
            }
          }
        }
      }
    )
    response = @fcm.send_message("projects/#{@project_id}", message)
  end
end
