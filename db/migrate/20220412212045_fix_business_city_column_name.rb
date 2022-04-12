class FixBusinessCityColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :businesses, :city, :city_id
  end
end
