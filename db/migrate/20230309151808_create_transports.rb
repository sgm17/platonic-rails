class CreateTransports < ActiveRecord::Migration[7.0]
  def change
    create_table :transports do |t|
      t.string :name, null: false
      t.integer :icon, null: false
      t.integer :minutes, null: false
      t.references :university, foreign_key: true, null: false
      t.timestamps
    end
  end
end
