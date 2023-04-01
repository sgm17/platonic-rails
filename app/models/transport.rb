class Transport < ApplicationRecord
    belongs_to :user

    has_and_belongs_to_many :flats, join_table: :flats_transports
end
