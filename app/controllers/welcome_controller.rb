require 'metoffice'
#require 'net/http'
#require 'uri'

class WelcomeController < ApplicationController

  DEFAULT_GEOG_MESSAGE = 'Postcode or address'
  COMPASS_POINTS = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW]
  TIMEOUT = 30
  API_KEY = '845d4be2-1112-4d73-b6a5-9624091a4bf7'

# forecast site list = http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/sitelist?key=845d4be2-1112-4d73-b6a5-9624091a4bf7
# data for a site =     http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/3772?res=3hourly&key=845d4be2-1112-4d73-b6a5-9624091a4bf7

#                       http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/nearestlatlon?res=3hourly&lat=57.001&lon=56.672&key=<API key>

  def fetch_raw_data(url)
    timeout(TIMEOUT) do
      uri = URI.parse(url)
      client = Net::HTTP.new(uri.host, uri.port)
      response = client.get(uri.request_uri)
      response.body
    end
  end

  def get_forecasts_for_location(lat,lng)
    ActiveSupport::JSON.decode(fetch_raw_data("http://partner.metoffice.gov.uk/public/val/wxfcs/all/json/nearestlatlon?res=3hourly&lat=#{lat}&lon=#{lng}&key=#{API_KEY}"))
  end

  def index
    # Loads of stuff hard coded that shouldn't be
    @week_text = 'next week'                     # hard code for now
    @warning = "Warning - weather forecasts are only available until #{(Time.now + 5.days).strftime('%A %I %p').gsub('0','')}.  After that it is really guesswork (using the last data point)."
    @mindays = 5
    @maxdays = 5
    @minhours = 5
    @maxhours = 40
    @geog1 = 'TN22 4EA'
    @geog2 = 'TN39 5BF'
  end

  def calculate
    # calculate direction (in both directions) and distance in miles
    @distance = Geocoder::Calculations.distance_between([params[:lat1].to_f,params[:lng1].to_f],[params[:lat2].to_f,params[:lng2].to_f],{:units => :mi})
    @bearing_in = Geocoder::Calculations.bearing_between([params[:lat1].to_f,params[:lng1].to_f],[params[:lat2].to_f,params[:lng2].to_f],{:units => :mi})
    @bearing_home = (@bearing_in + 180) % 360
    @direction = Geocoder::Calculations.compass_point(@bearing_in, COMPASS_POINTS)

    # We should look for intermediate points as well
    start_point_data = MetOffice.get_forecasts_for_location(params[:lat1],params[:lng1])
    end_point_data = MetOffice.get_forecasts_for_location(params[:lat2],params[:lng2])

    @sites = []
    @sites << start_point_data["SiteRep"]["DV"]["Location"]
    @sites << end_point_data["SiteRep"]["DV"]["Location"] if start_point_data["SiteRep"]["DV"]["Location"] != end_point_data["SiteRep"]["DV"]["Location"]

    # populate the days array with the next 5 days data
    @days = []
    start_point_data["SiteRep"]["DV"]["Location"]["Period"].each do |day|
      day_record = {}
      day_record["Date"] = Time.parse(day["@val"])
      day_record["9am"] = day["Rep"].select {|a| a["$"] == "540"}.first
      day_record["6pm"] = day["Rep"].select {|a| a["$"] == "1080"}.first
      @days << day_record
    end
  end

  def contact

  end

  def help

  end

  def about

  end

  def terms

  end

  def privacy

  end

  def opensource

  end

end
