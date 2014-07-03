module WeatherNewsChecker
  class Day
    def initialize(doc)
      @doc = doc
    end

    def precipitation
      @precipitation ||= @doc.css("precipitation > hour").map(&:text).map(&:to_i)
    end

    def start_hour
      @start_hour ||= @doc.attr("startHour").text.to_i
    end

    def temperature
      @temperature ||= @doc.css("temperature > hour").map(&:text).map(&:to_i)
    end

    def weather
      @weather ||= @doc.css("weather > hour").map(&:text).map(&:to_i)
    end

    def wind_direction
      @wind_direction ||= wind.map{ |wind| wind.css("direction").text.to_i }
    end

    def wind_value
      @wind_value ||= wind.map{ |wind| wind.css("value").text.to_i }
    end

    private

    def wind
      @wind ||= @doc.css("wind > hour")
    end
  end
end
