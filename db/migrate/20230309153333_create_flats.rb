class CreateFlats < ActiveRecord::Migration[7.0]
  def change
    create_table :flats do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :description, null: false
      t.point :geometry, null: false
      t.integer :currency, null: false
      t.integer :rent_price_per_month_in_cents, null: false
      t.integer :advance_price_in_cents, null: false
      t.integer :electricity_price_in_cents, null: false
      t.datetime :available_from, null: false
      t.decimal :max_months_stay, null: false
      t.decimal :min_months_stay, null: false
      t.string :tenants_number, null: false
      t.string :bedroom, null: false
      t.string :bathroom, null: false
      t.integer :built, null: false
      t.integer :floor, null: false
      t.timestamps
    end

    add_column :flats, :images, :text, array: true, default: []
  end
end
