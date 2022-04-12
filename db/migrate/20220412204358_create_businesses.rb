class CreateBusinesses < ActiveRecord::Migration[7.0]
  def change
    create_table :businesses do |t|
      t.integer :city
      t.string :yelp_id
      t.integer :rank
      t.string :name
      t.text :url
      t.text :image_url
      t.text :categories
      t.decimal :rating
      t.string :price

      t.timestamps
    end
  end
end
