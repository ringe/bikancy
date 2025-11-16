module StationTestHelpers
  module_function

  def sample_information_payload
    {
      "data" => {
        "stations" => [
          {
            "station_id" => 101,
            "name" => "Alpha",
            "address" => "Alpha Street 1",
            "cross_street" => "First & Main",
            "capacity" => 12,
            "lat" => 59.9123,
            "lon" => 10.7521
          },
          {
            "station_id" => 102,
            "name" => "Bravo",
            "address" => "Bravo Street 2",
            "cross_street" => "Second & Pine",
            "capacity" => 24,
            "lat" => 59.9134,
            "lon" => 10.7532
          }
        ]
      }
    }
  end

  def sample_status_payload
    timestamp = Time.utc(2023, 11, 1, 12, 0, 0).to_i

    {
      "data" => {
        "stations" => [
          {
            "station_id" => 101,
            "num_bikes_available" => 5,
            "last_reported" => timestamp
          },
          {
            "station_id" => 102,
            "num_bikes_available" => 19,
            "last_reported" => timestamp - 60
          }
        ]
      }
    }
  end

  def mock_bysykkel_client(info: sample_information_payload, status: sample_status_payload)
    mock = Minitest::Mock.new
    mock.expect :station_status, status
    mock.expect :station_information, info
    mock
  end

  def build_station(attributes = {})
    defaults = {
      station_id: 101,
      name: "Alpha",
      address: "Alpha Street 1",
      cross_street: "First & Main",
      capacity: 12,
      lat: 59.9123,
      lon: 10.7521,
      bikes_available: 5,
      updated_at: Time.utc(2023, 11, 1, 12, 0, 0)
    }

    Station.new(defaults.merge(attributes))
  end
end
