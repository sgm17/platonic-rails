class Api::V1::UniversitiesController < ApplicationController
  before_action :firebase_cloud_messaging, only: [:index]

    def index

      @firebase_cloud_messaging.send_push_notification(
        "fxfHocONQdeNUFzB9bJcFM:APA91bERXD_2u4Cgo6AJtBap2Stj6yryL4vopCIxivRlPDs4rvg35pLHGg4pvdrQ6njzxa-Tkmt2TBDUm3Fj4-Q0tnpbHvso9hd6wLCwJCCqdC8mnLopZ332jhvaXQzFAvJkhwChcwiz",
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
