class University < ApplicationRecord
    has_and_belongs_to_many :flats, class_name: "Flat", join_table: :flats_tenants_universities

    has_many :users
    has_many :faculties
    has_many :transports
end