class Story < ApplicationRecord
    belongs_to :user
    belongs_to :faculty
    has_many :favourites
end
