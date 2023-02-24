class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string "uid", null: false
      t.string "cloud_token"
      t.string "name", null: false
      t.integer "sex", null: false
      t.integer "age", null: false
      t.string "profile_image"
      t.string "meet_picture"

      t.references :university, null: false, foreign_key: true # University I belong to
      t.references :faculty, null: false, foreign_key: true # Faculty I belong to
      t.references :study, null: false, foreign_key: true # Study I belong to

      t.boolean "meet_status", null: false
      t.integer "sex_to_meet", null: false

      t.timestamps
    end
  end
end