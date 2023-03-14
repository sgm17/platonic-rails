class Faculty < ApplicationRecord
    has_many :users
    has_many :studies
    has_many :stories
    
    belongs_to :university
end
