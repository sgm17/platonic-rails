class CreateJoinTableflatUniversities < ActiveRecord::Migration[7.0]
  def change
    create_table :flats_tenants_universities do |t|
      t.belongs_to :flat
      t.belongs_to :university
    end
  end
end
