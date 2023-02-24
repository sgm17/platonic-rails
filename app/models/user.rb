class User < ApplicationRecord
    has_and_belongs_to_many :faculties_to_meet, class_name: 'Faculty'
    belongs_to :university
    belongs_to :faculty
    belongs_to :study
    has_many :favourites
end
