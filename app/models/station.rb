class Station
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :station_id,   :integer
  attribute :name,         :string
  attribute :address,      :string
  attribute :cross_street, :string
  attribute :capacity,     :integer
  attribute :lat,          :float
  attribute :lon,          :float

  attribute :bikes_available, :integer

  CACHE_KEY = "stations".freeze
  CACHE_TTL = 15.seconds

  def id
    station_id
  end

  def to_param
    station_id.to_s
  end

  def persisted?
    true
  end

  def self.all
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) do
      fetch_from_bysykkel
    end
  end

  def self.find(id)
    all.find { |station| station.id == id.to_i }
  end

  def self.fetch_from_bysykkel
    api = Bysykkel.new

    statuses = api.station_status.dig("data", "stations")

    json = api.station_information
    stations = json.dig("data", "stations").collect do |station|
      atts = station.slice(*Station.attribute_names)

      status = statuses.find { |s| s["station_id"] == station["station_id"] }
      atts["bikes_available"] = status["num_bikes_available"] rescue nil

      Station.new(atts)
    end
  end
end
