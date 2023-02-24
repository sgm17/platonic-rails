class CreateUserMeetFaculties < ActiveRecord::Migration[7.0]
  def change
    create_join_table :users, :faculties, table_name: :faculties_to_meet do |t|
      t.index [:user_id, :faculty_id]
      t.index [:faculty_id, :user_id]
    end
  end
end
