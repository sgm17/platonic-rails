Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      # Define your routes here for version 1

      # University routes
      resources :universities, only: [:index]

      # User routes
      resources :users do
        collection do
          put :cloud_token
        end
      end

      # Meet routes
      resources :meets, only: [:index, :destroy]

      # Story routes
      resources :stories, except: [:update] do
        member do
          put :toggle_favourite
        end
      end

      # Image routes
      resources :images, only: [:index, :create] do
        collection do
          post :create_multiple
        end
      end

      # Flats routes
      resources :flats do
        collection do
          get :index_home
        end
        post :bookmark, on: :member
        post :add_remove_tenant
      end

      # Visualization route
      resources :visualizations, only: [:create]
      
    end

    namespace :v2 do
      # Define your routes here for version 2
    end
  end
end
