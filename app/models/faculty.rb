class Faculty < ApplicationRecord
    # users that has faculties_to_meet
    has_and_belongs_to_many :meet_users, class_name: 'User', join_table: "faculties_users"
    
    has_many :users
    has_many :studies
    
    belongs_to :university
end
