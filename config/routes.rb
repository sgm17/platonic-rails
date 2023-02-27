Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      # Define your routes here for version 1

      # University routes
      resources :universities, only: [:index]

      # User routes
      resources :users, except: [:destroy]

      # Meet routes
      resources :meets, only: [:index]

      # Story routes
      resources :stories, except: [:update] do
        member do
          put :toggle_favourite
        end
      end
      
      # Conversations routes
      resources :conversations, only: [:index, :create] do
        resources :messages, only: [:create]
      end
      
    end

    namespace :v2 do
      # Define your routes here for version 2
    end
  end
end
