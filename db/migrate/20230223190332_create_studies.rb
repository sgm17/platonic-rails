class CreateStudies < ActiveRecord::Migration[7.0]
  def change
    create_table :studies do |t|
      t.string "name", null: false
      t.integer "courses", null: false
      t.references :faculty, foreign_key: true
      t.timestamps
    end
  end
end
