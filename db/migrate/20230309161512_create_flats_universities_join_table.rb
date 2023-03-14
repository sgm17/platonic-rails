class CreateFlatsUniversitiesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :flats_universities, id: false do |t|
      t.belongs_to :flat
      t.belongs_to :university
      t.index [:flat_id, :university_id], unique: true
    end
  end
end
