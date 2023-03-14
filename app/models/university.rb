class University < ApplicationRecord
    has_and_belongs_to_many :flats, join_table: :flats_tenants_universities

    has_many :users
    has_many :faculties
    has_many :transports
end