json.extract! station, :id, :id, :name, :address, :cross_street, :capacity, :lat, :lon, :bikes_available, :updated_at
json.url station_url(station, format: :json)
