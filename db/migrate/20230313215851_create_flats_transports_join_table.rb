class CreateFlatsTransportsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :flats_transports, id: false do |t|
      t.belongs_to :flat
      t.belongs_to :transport
      t.index [:flat_id, :transport_id], unique: true
    end
  end
end
