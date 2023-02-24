require_relative 'firebase_token'

class FirebaseAuthenticator
  def initialize(app)
    @app = app
  end

  def call(env)
      
    if env['PATH_INFO'] == '/api/v1/universities'
      # Skip authentication for this route
      @app.call(env)
    else
      auth_header = env['HTTP_AUTHORIZATION']
      if auth_header && auth_header.start_with?('Bearer ')
        id_token = auth_header.split(' ')[1]
        token = FirebaseToken.new(id_token)

        begin
          decoded_token = token.verify()
          env['firebase.user'] = decoded_token

        rescue StandardError => e
          [401, {'Content-Type' => 'application/json'}, [{error: 'Invalid Firebase ID token'}.to_json]]
        end
      end

      if env['firebase.user'].nil?
          [401, {'Content-Type' => 'application/json'}, [{error: 'Authorization header is missing or invalid'}.to_json]]
      else
        @app.call(env)
      end
    end
  end
end