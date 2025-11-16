require "test_helper"

class StationTest < ActiveSupport::TestCase
  setup do
    Rails.cache.delete(Station::CACHE_KEY)
  end

  teardown do
    Rails.cache.delete(Station::CACHE_KEY)
  end

  test ".all builds stations from Bysykkel data" do
    bysykkel_mock = StationTestHelpers.mock_bysykkel_client

    Bysykkel.stub :new, bysykkel_mock do
      stations = Station.all

      assert_equal 2, stations.size
      first = stations.first
      assert_kind_of Station, first
      assert_equal 101, first.id
      assert_equal "Alpha", first.name
      assert_equal 5, first.bikes_available
      expected_first_time = Time.at(StationTestHelpers.sample_status_payload.dig("data", "stations").first.fetch("last_reported"))
      assert_equal expected_first_time, first.updated_at

      last = stations.last
      assert_equal 102, last.id
      assert_equal "Bravo", last.name
      assert_equal 19, last.bikes_available
      expected_last_time = Time.at(StationTestHelpers.sample_status_payload.dig("data", "stations").last.fetch("last_reported"))
      assert_equal expected_last_time, last.updated_at
    end

    bysykkel_mock.verify
  end

  test ".all caches the fetched stations" do
    bysykkel_mock = StationTestHelpers.mock_bysykkel_client

    memory_store = ActiveSupport::Cache::MemoryStore.new
    Rails.stub(:cache, memory_store) do
      Bysykkel.stub :new, bysykkel_mock do
        first_ids = Station.all.map(&:id)
        second_ids = Station.all.map(&:id)

        assert_equal first_ids, second_ids, "Expected cached call to return the same stations"
      end
    end

    bysykkel_mock.verify
  end

  test ".find returns a station by id" do
    bysykkel_mock = StationTestHelpers.mock_bysykkel_client

    Bysykkel.stub :new, bysykkel_mock do
      station = Station.find(102)
      assert_equal "Bravo", station.name
      assert_equal 102, station.id
      assert_equal 19, station.bikes_available
    end

    bysykkel_mock.verify
  end

  test "#to_param returns station id as string" do
    station = StationTestHelpers.build_station(station_id: 404)
    assert_equal "404", station.to_param
  end
end
