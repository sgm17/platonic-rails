class Faculty < ApplicationRecord
    has_and_belongs_to_many :meet_users, class_name: 'User'
    has_many :users
    has_many :studies
    
    belongs_to :university
end
