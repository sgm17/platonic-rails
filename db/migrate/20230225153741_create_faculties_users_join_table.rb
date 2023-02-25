class CreateFacultiesUsersJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :faculties_users, id: false do |t|
      t.belongs_to :faculty
      t.belongs_to :user
    end

    add_index :faculties_users, [:faculty_id, :user_id], unique: true
  end
end
