require 'httparty'

module ApiHelper

  BUSINESS_SEARCH_URL = 'https://api.yelp.com/v3/businesses/search'
  
  AUTH_HEADER = {
    'Authorization': "Bearer #{ENV['YELP_API_KEY']}"
  }

  def getCachedResultsByCity(cityName)

    # if we cached > 24 hours ago, we'll pretend like they don't exist as per Yelp's guidelines
    # https://www.yelp.com/developers/display_requirements

    return nil
  end

  def cacheResultsByCity(cityName, results)
    Rails.logger.info "Caching results for #{cityName}"
    return true
  end

  def searchByCity(cityName)
    cachedValue = getCachedResultsByCity(cityName)

    if cachedValue then
      return cachedValue
    end

    results = []

    searchUrl = BUSINESS_SEARCH_URL + "?location=#{ERB::Util.url_encode(cityName)}&limit=10"
    Rails.logger.info AUTH_HEADER
    res = HTTParty.get(searchUrl, :headers => AUTH_HEADER)
   
    Rails.logger.info "Response code is #{res.code}"

    if res.code == 200 then
      parsed_results = JSON.parse(res.body, :symbolize_names => true)

      results = parsed_results[:businesses].map do |b|
        Rails.logger.info b
        
        {
          "id": b[:id],
          "name": b[:name],
          "url": b[:url],
          "image": b[:image_url],
          "categories": b[:categories].map {|c| c[:title] },
          "rating": b[:rating],
          "price": b[:price]
        }
      end

      Rails.logger.info "SUCCESS!"
      Rails.logger.info results
    else
      Rails.logger.info "Failure :( #{res.code}"
      Rails.logger.info res.body
    end

    # cache if not already present
    if results.length > 0 then
      cacheResultsByCity(cityName, results)
    end

    return results
  end


end
