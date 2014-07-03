require "nokogiri"
require "open-uri"

module WeatherNewsChecker
  class Weather
    class << self
      def weather_at(postal_code)
        parse_weather_xml_at(observatory_id_at(postal_code))
      end

      private

      # input : "WriteSWF('/pinpoint/swf/pinpoint2.swf?201006172', '760', '585', '&pointName=[152-0033]東京都目黒区大岡山&obsOrg=44166&xmlFile=../xml/44166_410001442.xml&areaNo=440');count();"
      # output: 44166
      def extract_observatory_id(onload_str)
        onload_str.split("&").select { |s| /\AobsOrg/ =~ s }.first.split("=")[1].to_i
      end

      def observatory_id_at(postal_code)
        doc = Nokogiri::HTML.parse(open(search_result_url(postal_code)).read)
        onload_str = doc.css("body").attr("onload").text
        extract_observatory_id(onload_str)
      end

      def parse_day_weather(day)
        start_hour = day.attr("startHour").text.to_i
        weather_array = day.css("weather > hour")
        temperature_array = day.css("temperature > hour")
        wind_array = day.css("wind > hour")
        precipitation_array = day.css("precipitation > hour")

        result = []

        weather_array.map(&:text).each_with_index do |weather_value, i|
          result << {
                     hour: (start_hour + i) % 24,
                     weather: weather_of(weather_value.to_i / 100),
                     temperature: temperature_array[i].text.to_i,
                     wind_direction: direction_of(wind_array[i].css("direction").text.to_i),
                     wind_value: wind_array[i].css("value").text.to_i,
                     precipitation: precipitation_array[i].text.to_i
                    }
        end

        result
      end

      def parse_week_weather(week)

      end

      def parse_weather_xml_at(observatory_id)
        doc = Nokogiri::XML.parse(open(weather_xml_url(observatory_id)))
        {
          day: parse_day_weather(doc.xpath("/weathernews/data/day")),
        }
      end

      def direction_of(index)
        %i(n ne e se s sw w nw)[index / 2]
      end

      def weather_of(index)
        %i(sunny cloudy rainy)[index - 1]
      end

      def search_result_url(postal_code)
        "http://weathernews.jp/pinpoint/cgi/search_result.fcgi?service=3&post=#{postal_code}"
      end

      def weather_xml_url(observatory_id)
        "http://weathernews.jp/pinpoint/xml/#{observatory_id}.xml"
      end
    end
  end
end
