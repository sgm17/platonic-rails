class Transport < ApplicationRecord
    has_and_belongs_to_many :flats, join_table: :flats_transports
    belongs_to :university
end
