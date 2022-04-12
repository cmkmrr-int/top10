require 'httparty'

module ApiHelper

  BUSINESS_SEARCH_URL = 'https://api.yelp.com/v3/businesses/search'
  AUTH_HEADER = {
    'Authorization': "Bearer #{ENV['YELP_API_KEY']}"
  }
  SECS_IN_DAY = 86400

  def getCachedResultsByCity(cityName)

    # if we cached > 24 hours ago, we'll pretend like they don't exist as per Yelp's guidelines
    # https://www.yelp.com/developers/display_requirements
    city = City.find_by(name: cityName)
    return nil unless city
    Rails.logger.info "Time diff is #{Time.now.utc - city.cached}"
    return nil unless Time.now.utc - city.cached < SECS_IN_DAY

    businesses = city.businesses.order('rank asc')

    # if we have no results, we'll return nothing to try again
    return nil if businesses.length == 0

    businesses.map { |b| b.to_dict }
  end

  def cacheResultsByCity(cityName, results)
    Rails.logger.info "Caching results for #{cityName}"

    # note: we likely would want to do this as a transaction in the db, so we don't have multiple writers
    # we could also take out a lock (redis, db, etc) to ensure that only if you have the lock do you write
    # data from the cache
    # Since this is just a demo app, i'll skip that and just do the naive thing which will work in a single user env

    city = City.find_by(name: cityName)
    Rails.logger.info "HERE #{city}"
    if city.nil? then
      Rails.logger.info "City was nil"
      city = City.new
      city.name = cityName
      city.save
    end

    # clear any potential results
    Business.where(:city => city.id).delete_all
    
    # save new results
    results.each do |b|
      Rails.logger.info b
      bus = Business.new
      bus.city = city
      bus.yelp_id = b[:id]
      bus.name = b[:name]
      bus.url = b[:url]
      bus.image_url = b[:image]
      bus.categories = b[:categories].join(",")
      bus.rating = b[:rating]
      bus.price = b[:price]
      bus.rank = b[:rank]
      bus.save
    end 

    # update cache time
    city.cached = Time.now.utc
    city.save
    return true
  end

  def searchByCity(cityName)
    cachedValue = getCachedResultsByCity(cityName)

    if cachedValue then
      Rails.logger.info "Returning cached results for #{cityName}"
      return cachedValue
    end
    Rails.logger.info "No cached results for #{cityName}"

    results = []

    searchUrl = BUSINESS_SEARCH_URL + "?location=#{ERB::Util.url_encode(cityName)}&limit=10"
    res = HTTParty.get(searchUrl, :headers => AUTH_HEADER)
   
    if res.code == 200 then
      parsed_results = JSON.parse(res.body, :symbolize_names => true)

      results = parsed_results[:businesses].map.with_index do |b, idx|
        {
          "id": b[:id],
          "name": b[:name],
          "url": b[:url],
          "image": b[:image_url],
          "categories": b[:categories].map {|c| c[:title] },
          "rating": b[:rating],
          "price": b[:price],
          "rank": idx
        }
      end

    else
      Rails.logger.info "Failed search for #{cityName} -- response code #{res.code}"
    end

    # cache if not already present
    if results.length > 0 then
      cacheResultsByCity(cityName, results)
    end

    return results
  end

end
