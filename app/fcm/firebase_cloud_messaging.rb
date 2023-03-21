require 'httparty'

class FirebaseCloudMessaging
    endpoint = 'https://fcm.googleapis.com/v1/projects/platonic-3bc9d/messages:send'
    access_token = '4/0AWtgzh59rpIcwwNAVfUoVlSdNhaAsCvNYe5wyxqJAEs24CK8FP8pvYYHeWSxo6Huzhxz5w'

    def send_push_notification(cloud_token)
        notification_title_key = 'your-notification-title-key' # This is the key that can later be translated in your Flutter app for the title
        notification_message_key = 'your-notification-message-key' # This is the key that can later be translated in your Flutter app for the message
        
        notification_data = {
            title_loc_key: notification_title_key,
            body_loc_key: notification_message_key,
        }
        
        # Set the request headers
        headers = {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{access_token}",
        }
        
        # Set the request body
        body = {
            message: {
            token: cloud_token,
            notification: notification_data,
        },
        }
        
        # Send the request to the Firebase Cloud Messaging API
        response = HTTParty.post(endpoint, headers: headers, body: body.to_json)
    end
end