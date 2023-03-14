class Story < ApplicationRecord
    belongs_to :user
    belongs_to :faculty
    
    has_many :favourites, dependent: :destroy
    has_many :visualizations, dependent: :destroy
end
