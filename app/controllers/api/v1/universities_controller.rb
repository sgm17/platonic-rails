class Api::V1::UniversitiesController < ApplicationController
    def index
        universities = University.all.includes(faculties: :studies)

        render json: universities
    end
end
