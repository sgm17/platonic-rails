class Api::V1::UniversitiesController < ApplicationController
    def index
      universities = University.all.includes(faculties: :studies).map do |university|
          {
            id: university.id,
            university: {
              id: university.id,
              name: university.name,
              simple_name: university.simple_name
            },
            faculties: university.faculties.map do |faculty|
              {
                id: faculty.id,
                faculty_name: faculty.faculty_name,
                studies: faculty.studies.map do |study|
                  {
                    id: study.id,
                    study_name: study.study_name,
                  }
                end
              }
            end
          }
      end
      render json: universities
    end
end
