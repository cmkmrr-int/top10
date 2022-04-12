class Business < ApplicationRecord
  belongs_to :city

  def to_dict
    {
	"id": yelp_id,
        "name": name,
        "url": url,
        "image": image_url,
        "categories": categories.split(','),
        "rating": rating,
        "price": price
    }
  end
end
