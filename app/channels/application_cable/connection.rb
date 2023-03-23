module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = authenticate_user
    end

    def authenticate_user
      current_user ||= User.find_by(uid: request.env['firebase.user'][0]['user_id'])
      
      if current_user
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
