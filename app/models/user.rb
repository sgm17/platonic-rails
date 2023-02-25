class User < ApplicationRecord
    # faculties_to_meet by the user
    has_and_belongs_to_many :faculties_to_meet, class_name: 'Faculty'

    # unviersity_to_meet by the users
    belongs_to :university_to_meet, class_name: 'University', foreign_key: 'university_to_meet_id'

    # unviersity that belongs to the user
    belongs_to :university, class_name: 'University', foreign_key: 'university_id'
    # faculty that belongs to the user 
    belongs_to :faculty, class_name: 'Faculty', foreign_key: 'faculty_id'
    # study that belongs to the user
    belongs_to :study

    # favourites that the user set to the stories
    has_many :favourites
end
