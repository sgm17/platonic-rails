class ApplicationController < ActionController::API
    def current_user
        #return unless request.env['firebase.user']
        #@current_user ||= User.find_by(uid: request.env['firebase.user'][0]['user_id'])
        @current_user = User.find_by(uid: 'hR1NbH4yhsMZJ9aZJuzqErzBwPJ3')
    end
end
