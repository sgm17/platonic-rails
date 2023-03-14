class CreateFlatsTenantsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :flats_tenants, id: false do |t|
      t.belongs_to :flat
      t.belongs_to :user
      t.index [:flat_id, :user_id], unique: true
    end
  end
end
