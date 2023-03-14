class CreateFlatsFeaturesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :flats_features, id: false do |t|
      t.belongs_to :flat
      t.belongs_to :feature
      t.index [:flat_id, :feature_id], unique: true
    end
  end
end
