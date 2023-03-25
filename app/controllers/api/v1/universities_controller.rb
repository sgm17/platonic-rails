class Api::V1::UniversitiesController < ApplicationController
  before_action :firebase_cloud_messaging, only: [:index]

    def index

      @firebase_cloud_messaging.send_push_notification(
        "fKGsQZRvQq6TqHr2R-WbRx:APA91bFs9iH9SRC3odYxLEpZd9gUff3JvWjJ6xLZ_bwFw57aotJ98vITa5_MtzyXdT0S4WE_IrIftw6oBjgXXZslHtBwhiHqiJZctpXIkp-91LB51NS8kgiq9TkxhuHcjfOFdZm-4PEa",
        "title",
        "body",
        "title_key",
        "body_key"
      )

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
