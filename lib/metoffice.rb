require 'net/http'
require 'uri'

TIMEOUT = 30
API_KEY = '845d4be2-1112-4d73-b6a5-9624091a4bf7'

# forecast site list = http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/sitelist?key=845d4be2-1112-4d73-b6a5-9624091a4bf7
# data for a site =     http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/3772?res=3hourly&key=845d4be2-1112-4d73-b6a5-9624091a4bf7

#                       http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/nearestlatlon?res=3hourly&lat=57.001&lon=56.672&key=<API key>

module MetOffice

  class Forecast

  end

  def MetOffice.fetch_raw_data(url)
    timeout(TIMEOUT) do
      uri = URI.parse(url)
      client = Net::HTTP.new(uri.host, uri.port)
      response = client.get(uri.request_uri)
      response.body
    end
  end

  def MetOffice.get_forecasts_for_location(lat,lng)
    ActiveSupport::JSON.decode(fetch_raw_data("http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/nearestlatlon?res=3hourly&lat=#{lat}&lon=#{lng}&key=#{API_KEY}"))
  end

end