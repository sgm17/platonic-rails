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

    # bookmarks that the user set to the flats
    has_many :bookmarks

    # users has many stories
    has_many :stories

    # users has many stories
    has_many :flats

    # user has many meets
    has_many :meets_as_user1, class_name: "Meet", foreign_key: "user1_id"
    has_many :meets_as_user2, class_name: "Meet", foreign_key: "user2_id"

    # user has many conversations
    has_many :initiated_conversations, class_name: "Conversation", foreign_key: "user1_id"
    has_many :received_conversations, class_name: "Conversation", foreign_key: "user2_id"
    
    # Define a method to get all meets for a user
    def meets
        Meet.where("user1_id = ? OR user2_id = ?", id, id)
    end

    def conversations
        Conversation.where("user1_id = ? OR user2_id = ?", id, id)
    end
end
