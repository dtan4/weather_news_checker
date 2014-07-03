require "spec_helper"

module WeatherNewsChecker
  describe Weather do
    describe "#weather_at" do
      let(:weather_at) do
        described_class.weather_at(postal_code)
      end

      context "when valid postal code is given" do
        let(:postal_code) do
          "1520033"
        end

        before do
          stub_request(:get, "http://weathernews.jp/pinpoint/cgi/search_result.fcgi?service=3&post=#{postal_code}").to_return(status: 200, body: open(fixture_path("search_result.html")))
          stub_request(:get, "http://weathernews.jp/pinpoint/xml/44166.xml").to_return(status: 200, body: open(fixture_path("weather.xml")))
        end

        it "should return weather at the point" do
          expect(weather_at[:day].length).to eq 42
          expect(weather_at[:day][0]).to eq({
                                             hour: 16, weather: :cloudy,
                                             precipitation: 0,
                                             temperature: 25,
                                             wind_direction: :s, wind_value: 6
                                            })
        end
      end

      context "when invalid postal code is given" do
        let(:postal_code) do
          "invalid"
        end

        before do
          stub_request(:get, "http://weathernews.jp/pinpoint/cgi/search_result.fcgi?service=3&post=#{postal_code}").to_return(status: 404)
        end

        it "should raise ArgumentError" do
          expect do
            postal_code
          end.to raise_error ArgumentError
        end
      end
    end
  end
end
