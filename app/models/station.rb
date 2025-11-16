class Station
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,            :integer
  attribute :name,          :string
  attribute :address,       :string
  attribute :cross_street,  :string
  attribute :capacity,      :integer
  attribute :lat,           :float
  attribute :lon,           :float

  attribute :bike_vacancy,  :integer

  CACHE_KEY = "stations".freeze
  CACHE_TTL = 15.seconds

  def self.all
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) do
      fetch_from_bysykkel
    end
  end

  def self.find(name)
    all.find { |station| station.name == name }
  end

  def self.fetch_from_bysykkel
    api = Bysykkel.new
    json = api.station_information
    stations = json.dig("data", "stations").collect do |station|
      atts = station.slice(*Station.attribute_names)
      atts["id"] = station["station_id"]
      Station.new(atts)
    end
  end
end
