class ApplicationController < ActionController::API
    def current_user
        return unless env['firebase.user']

        @current_user ||= User.find_by(uid: env['firebase.user']['uid'])
    end
end
