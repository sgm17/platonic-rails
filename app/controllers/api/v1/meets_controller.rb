class Api::V1::MeetsController < ApplicationController
    before_action :set_meet, only: [:show, :update, :destroy]
  
    # GET /api/v1/meets
    def index
      meets = current_user.meets.includes(:user)
  
      render json: meets.map { |meet| meet.user }
    end
  
    # GET /api/v1/meets/1
    def show
      render json: @meet
    end
  
    # POST /api/v1/meets
    def create
      @meet = Meet.new(meet_params)
      @meet.user = current_user
  
      if @meet.save
        render json: @meet, status: :created, location: api_v1_meet_url(@meet)
      else
        render json: @meet.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /api/v1/meets/1
    def update
      if @meet.update(meet_params)
        render json: @meet
      else
        render json: @meet.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /api/v1/meets/1
    def destroy
      @meet.destroy
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_meet
      @meet = current_user.meets.find(params[:id])
    end
  
    # Only allow a trusted parameter "white list" through.
    def meet_params
      params.require(:meet).permit(:user_id, :location, :time, :description)
    end
  end
  