class User < ApplicationRecord
    # faculties_to_meet by the user
    has_and_belongs_to_many :faculties_to_meet, class_name: 'Faculty', join_table: :faculties_users

    # unviersity_to_meet by the users
    belongs_to :university_to_meet, class_name: 'University'

    # unviersity that belongs to the user
    belongs_to :university
    # faculty that belongs to the user 
    belongs_to :faculty
    # study that belongs to the user
    belongs_to :study

    # favourites that the user set to the stories
    has_many :favourites, dependent: :destroy

    # bookmarks that the user set to the flats
    has_many :bookmarks, dependent: :destroy

    # visualizations that the user set to the stories
    has_many :visualizations, dependent: :destroy

    # user has many stories
    has_many :stories, dependent: :destroy

    # user has many flats
    has_many :flats, foreign_key: :owner_id, dependent: :destroy, class_name: 'Flat'

    # user has many transports
    has_many :transports, dependent: :destroy

    # user has many meets
    has_many :meets_as_user1, class_name: "Meet", foreign_key: "user1_id", dependent: :destroy
    has_many :meets_as_user2, class_name: "Meet", foreign_key: "user2_id", dependent: :destroy

    # user has many conversations
    has_many :initiated_conversations, class_name: "Conversation", foreign_key: "user1_id", dependent: :destroy
    has_many :received_conversations, class_name: "Conversation", foreign_key: "user2_id", dependent: :destroy
    
    # Define a method to get all meets for a user
    def meets
        Meet.where("user1_id = ? OR user2_id = ?", id, id)
    end

    def conversations
        Conversation.where("user1_id = ? OR user2_id = ?", id, id)
    end
end
