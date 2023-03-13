class CreateUniversities < ActiveRecord::Migration[7.0]
  def change
    create_table :universities do |t|
      t.string :name, null: false
      t.string :simple_name, null: false
      t.timestamps
    end
  end
end
