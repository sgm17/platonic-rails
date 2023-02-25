Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      # Define your routes here for version 1

      # Routes without middleware
      resources :universities, only: [:index]

      # Routes with middleware

      resources :stories do
        member do
          put :toggle_favourite
        end
      end

      resources :users
      resources :meets, only: [:index]
      
      resources :conversations do
        resources :messages, only: [:create]
      end
      
    end

    namespace :v2 do
      # Define your routes here for version 2
    end
  end
end
