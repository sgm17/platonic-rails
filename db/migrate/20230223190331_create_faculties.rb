class CreateFaculties < ActiveRecord::Migration[7.0]
  def change
    create_table :faculties do |t|
      t.string "faculty_name", null: false
      t.references :university, foreign_key: true
      t.timestamps
    end
  end
end
