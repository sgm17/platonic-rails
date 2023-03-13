class CreateStories < ActiveRecord::Migration[7.0]
  def change
    create_table :stories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :faculty, null: false, foreign_key: true
      t.string :body, null: false
      t.integer :background_gradient_index, null: false
      t.datetime :creation_date, null: false

      t.timestamps
    end
  end
end
