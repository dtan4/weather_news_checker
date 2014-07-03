require "spec_helper"

module WeatherNewsChecker
  describe Day do
    let(:doc) do
      Nokogiri::XML.parse(open(fixture_path("weather.xml")).read).xpath("/weathernews/data/day")
    end

    let(:day) do
      described_class.new(doc)
    end

    describe "#precipitation" do
      it "should return Array" do
        expect(day.precipitation).to be_a Array
        expect(day.precipitation[0]).to eq 0
      end
    end

    describe "#start_hour" do
      it "should return start hour" do
        expect(day.start_hour).to eq 16
      end
    end

    describe "#temperature" do
      it "should return Array" do
        expect(day.temperature).to be_a Array
        expect(day.temperature[0]).to eq 25
      end
    end

    describe "#weather" do
      it "should return Array" do
        expect(day.weather).to be_a Array
        expect(day.weather[0]).to eq 200
      end
    end

    describe "#wind_direction" do
      it "should return Array" do
        expect(day.wind_direction).to be_a Array
        expect(day.wind_direction[0]).to eq 8
      end
    end

    describe "#wind_value" do
      it "should return Array" do
        expect(day.wind_value).to be_a Array
        expect(day.wind_value[0]).to eq 6
      end
    end
  end
end
