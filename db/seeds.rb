# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
require 'json'

# Load universities from JSON file
universities_file = Rails.root.join('app', 'assets', 'universities', 'universities.json')
universities_data = JSON.parse(File.read(universities_file), encoding: 'utf-8')

# Create universities, faculties, and studies
universities_data.each do |university_data|
  university = University.create!(
    name: university_data['name'],
    simple_name: university_data['simple_name']
  )

  university_data['faculties'].each do |faculty_data|
    faculty = Faculty.create!(
      faculty_name: faculty_data['faculty_name'],
      university: university
    )

    faculty_data['studies'].each do |study_data|
      Study.create!(
        study_name: study_data["study_name"],
        faculty: faculty
      )
    end
  end
end

# Create features
features = [
  {name: "Wi-Fi", icon: 59111},
  {name: "Air Conditioning", icon: 57399},
  {name: "Heating", icon: 58159},
  {name: "Closet", icon: 57693},
  {name: "Dishwasher", icon: 58006},
  {name: "Microwave", icon: 58342},
  {name: "Oven", icon: 57994},
  {name: "Refrigerator", icon: 58206},
  {name: "Smoke", icon: 58823},
  {name: "Elevator", icon: 57897},
  {name: "Garage", icon: 58066},
  {name: "Laundry", icon: 58264},
  {name: "Furnitures", icon: 985207},
  {name: "Gym", icon: 57997},
  {name: "Pool", icon: 58588},
  {name: "Balcony", icon: 57546},
  {name: "Local Library", icon: 58265},
  {name: "Terrace", icon: 57783}
]

features.each do |feature|
  Feature.create(name: feature[:name], icon: feature[:icon])
end