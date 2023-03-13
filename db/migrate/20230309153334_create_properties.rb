class CreateProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :properties do |t|
      t.references :flat, foreign_key: true, null: false
      t.string :country, null: false
      t.string :city, null: false
      t.string :countrycode, null: false
      t.string :postcode, null: false
      t.string :county
      t.string :housenumber
      t.string :name, null: false
      t.string :state, null: false
      t.timestamps
    end
  end
end
