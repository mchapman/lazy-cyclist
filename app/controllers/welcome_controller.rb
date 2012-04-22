require 'metoffice'

class WelcomeController < ApplicationController

  DEFAULT_GEOG_MESSAGE = 'Postcode or address'
  COMPASS_POINTS = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW]
  DELTA = 0.00001

  def index
    # Loads of stuff hard coded that shouldn't be - should be cookies eventually
    @week_text = 'next week'                     # hard code for now
    @warning = "Warning - weather forecasts are only available until #{(Time.now + 5.days).strftime('%A %I %p').gsub('0','')}.  After that it is really guesswork (using the last data point)."
    @mindays = 5
    @maxdays = 5
    @minhours = 5
    @maxhours = 40
  end

  def calculate
    lat1 = params[:lat1].to_f
    lng1 = params[:lng1].to_f
    lat1, lng1 = Geocoder.coordinates(params[:geog1]+', UK') if lat1 < DELTA.abs && lng1 < DELTA.abs
    redirect_to :root_path, :alert => 'Cannot geocode ' + params[:geog1] if lat1 < DELTA.abs && lng1 < DELTA.abs
    lat2 = params[:lat2].to_f
    lng2 = params[:lng2].to_f
    lat2, lng2 = Geocoder.coordinates(params[:geog2]+', UK') if lat2 < DELTA.abs && lng2 < DELTA.abs
    redirect_to :root_path, :alert => 'Cannot geocode ' + params[:geog1] if lat2 < DELTA.abs && lng2 < DELTA.abs

    # calculate direction (in both directions) and distance in miles
    @distance = Geocoder::Calculations.distance_between([lat1, lng1], [lat2, lng2],{:units => :mi})
    @bearing_in = Geocoder::Calculations.bearing_between([lat1, lng1], [lat2, lng2],{:units => :mi})
    @bearing_home = (@bearing_in + 180) % 360
    @direction = Geocoder::Calculations.compass_point(@bearing_in, COMPASS_POINTS)

    # We should look for intermediate points as well
    Rails.logger.info "#{lat1}, #{lng1}, #{lat2}, #{lng2}"
    start_point_data = MetOffice.get_forecasts_for_location(lat1,lng1)
    end_point_data = MetOffice.get_forecasts_for_location(lat2,lng2)

    @sites = []
    @sites << start_point_data["SiteRep"]["DV"]["Location"]
    @sites << end_point_data["SiteRep"]["DV"]["Location"] if start_point_data["SiteRep"]["DV"]["Location"] != end_point_data["SiteRep"]["DV"]["Location"]
    # just use the start point for now - need to get a bit more sophisticated later

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
