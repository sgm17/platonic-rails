# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
require 'json'

# Load universities from JSON file
universities_file = Rails.root.join('app', 'assets', 'universities', 'universities.json')
universities_data = JSON.parse(File.read(universities_file))

# Create universities, faculties, and studies
universities_data.each do |university_data|
  university = University.create!(
    name: university_data['name'],
    simple_name: university_data['simpleName']
  )

  university_data['faculties'].each do |faculty_data|
    faculty = Faculty.create!(
      faculty_name: faculty_data['facultyName'],
      university: university
    )

    faculty_data['studies'].each do |study_data|
      Study.create!(
        name: study_data["name"],
        courses: study_data['courses'],
        faculty: faculty
      )
    end
  end
end
