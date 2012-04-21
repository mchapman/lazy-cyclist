module WelcomeHelper

  COMPASS_POINTS = %w[N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW]

  def conditions(forecast, direction)
    if forecast
      result = []
      result << "Gusty" if (forecast["@G"].to_i > 20)
      result << "Horrible" if forecast["@W"].to_i.between?(15,31)
#      result << forecast["@D"]
      if forecast["@S"].to_i > 8
        # ignore light winds
        seg_size = 360.0 / COMPASS_POINTS.length
        wind_bearing = COMPASS_POINTS.index(forecast["@D"]) * seg_size
#        result << wind_bearing
        helpful = (wind_bearing - direction).abs   # 0 is in face 180 is behind
        if helpful > 135
          wind_effect = "Whoosh"
        elsif helpful < 45
          wind_effect = "Grind"
        end
        wind_effect.upcase! if forecast["@S"].to_i > 15
        result << wind_effect
      end
      result.join(' ')
    else
      "No data"
    end
  end

  def display_day(day_hash)
    if day_hash["Date"].day == Time.now.day
      "Today"
    elsif day_hash["Date"].day == Time.now.day + 1
      "Tomorrow"
    else
      day_hash["Date"].strftime('%A')
    end
  end

end
