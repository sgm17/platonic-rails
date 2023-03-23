require 'httparty'

class FirebaseCloudMessaging
  FCM_ENDPOINT = 'https://fcm.googleapis.com/v1/projects/<project_id>/messages:send'.freeze
  TOKEN_ENDPOINT = 'https://oauth2.googleapis.com/token'.freeze

  def initialize(client_id, client_secret, refresh_token)
    @client_id = client_id
    @client_secret = client_secret
    @refresh_token = refresh_token
    @access_token = nil
  end

  def send_push_notification(cloud_token, notification_title_key, notification_message_key)
    # Set the request headers
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{access_token}",
    }

    # Set the notification data
    notification_data = {
      title_loc_key: notification_title_key,
      body_loc_key: notification_message_key,
    }

    # Set the request body
    body = {
      message: {
        token: cloud_token,
        notification: notification_data,
      },
    }

    # Send the request to the Firebase Cloud Messaging API
    response = HTTParty.post(FCM_ENDPOINT, headers: headers, body: body.to_json)

    if response.success?
      puts 'Push notification sent successfully'
    else
      puts 'Error sending push notification'
      puts "Response code: #{response.code}"
      puts "Response body: #{response.body}"
    end
  end

  private

  def access_token
    @access_token ||= refresh_access_token
  end

  def refresh_access_token
    # Set the request headers
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
    }

    # Set the request body
    body = {
      client_id: @client_id,
      client_secret: @client_secret,
      refresh_token: @refresh_token,
      grant_type: 'refresh_token',
    }

    # Send the request to the token endpoint
    response = HTTParty.post(TOKEN_ENDPOINT, headers: headers, body: URI.encode_www_form(body))

    if response.success?
      json_response = JSON.parse(response.body)
      json_response['access_token']
    else
      raise "Error refreshing access token: #{response.code} #{response.body}"
    end
  end
end
