require "test_helper"

class StationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stations = [
      StationTestHelpers.build_station(
        station_id: 101,
        name: "Alpha",
        bikes_available: 5,
        updated_at: Time.utc(2023, 11, 1, 12, 0, 0)
      ),
      StationTestHelpers.build_station(
        station_id: 102,
        name: "Bravo",
        bikes_available: 19,
        updated_at: Time.utc(2023, 11, 1, 11, 59, 0)
      )
    ]
  end

  test "GET /stations renders the station listing" do
    with_station_stubs do
      get stations_url
      assert_response :success
      assert_select "h1", "Stations"
      assert_select "td", text: "Alpha"
      assert_select "td", text: "Bravo"
    end
  end

  test "GET /stations.json returns serialized stations" do
    with_station_stubs do
      get stations_url(format: :json)
      assert_response :success

      payload = JSON.parse(response.body)
      assert_equal 2, payload.size
      first = payload.first

      assert_equal 101, first["station_id"]
      assert_equal "Alpha", first["name"]
      assert_equal 5, first["bikes_available"]
      assert first["url"].include?("/stations/101")
    end
  end

  test "GET /stations/:id renders the station detail" do
    with_station_stubs do
      get station_url(@stations.first)
      assert_response :success
      assert_select "strong", text: "Name:"
      assert_select "div", text: /Alpha/
    end
  end

  test "GET /stations/:id.json returns a station JSON document" do
    with_station_stubs do
      get station_url(@stations.last, format: :json)
      assert_response :success

      payload = JSON.parse(response.body)
      assert_equal 102, payload["station_id"]
      assert_equal "Bravo", payload["name"]
      assert_equal 19, payload["bikes_available"]
      assert payload["url"].end_with?("/stations/102.json")
    end
  end

  private

  def with_station_stubs
    Station.stub(:all, @stations) do
      Station.stub(:find, ->(id) { @stations.find { |station| station.id == id.to_i } }) do
        yield
      end
    end
  end
end
