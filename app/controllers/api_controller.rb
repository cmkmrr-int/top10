class ApiController < ApplicationController
  skip_forgery_protection # note: I did this so I could make local requests from localhost (& with port forwardiong)
  include ApiHelper

  def getTop10ByCity
    searchCity = params[:searchCity]

    results = searchByCity(searchCity)
    render json: {
      items: results
    }
  end

end
