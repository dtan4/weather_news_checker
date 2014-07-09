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
        result = []

        day.weather.each_with_index do |weather_value, i|
          result << {
                     hour: (day.start_hour + i) % 24,
                     weather: weather_of(weather_value / 100),
                     temperature: day.temperature[i],
                     wind_direction: direction_of(day.wind_direction[i]),
                     wind_value: day.wind_value[i],
                     precipitation: day.precipitation[i]
                    }
        end

        result
      end

      def parse_week_weather(week)

      end

      def parse_weather_xml_at(observatory_id)
        doc = Nokogiri::XML.parse(open(weather_xml_url(observatory_id)))
        day = Day.new(doc.xpath("/weathernews/data/day"))

        {
          day: parse_day_weather(day),
        }
      end

      def direction_of(index)
        %i(ne e se s sw w nw n)[index / 2 - 1]
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
