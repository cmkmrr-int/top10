class ApiController < ApplicationController
  skip_forgery_protection # note: I did this so I could make local requests from localhost (& with port forwardiong)
  include ApiHelper

  def getTop10ByCity
    searchCity = params[:searchCity]

    Rails.logger.info params

    if searchCity == 'a' then
      render json: {
        items: []
      }

    elsif searchCity == 'b' then
      render "hello world"
    else
      results = searchByCity(searchCity)
      render json: {
        items: results
      }
    end
  end

end
