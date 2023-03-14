class Flat < ApplicationRecord
    belongs_to :owner, class_name: "User", foreign_key: "owner_id"
    
    has_one :properties, dependent: :destroy
    has_many :bookmarks, dependent: :destroy

    has_and_belongs_to_many :universities, join_table: :flats_tenants_universities
    has_and_belongs_to_many :tenants, class_name: "User", join_table: :flats_tenants
    has_and_belongs_to_many :features, join_table: :flats_features
    has_and_belongs_to_many :transports, join_table: :flats_transports

    def bookmarked_by?(user)
        bookmarks.exists?(user_id: user.id)
    end
end
