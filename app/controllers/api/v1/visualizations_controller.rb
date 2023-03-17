class Api::V1::VisualizationsController < ApplicationController
    before_action :current_user, only: [:create]

    # POST /api/v1/visualizations
    def create
        story = Story.find(params[:story_id])

        visualization = story.visualizations.build(user: @current_user)
        
        if visualization.save
            render json: { visualization: true }, status: :created
        else
            render json: { visualization: false }
        end
    end
end
