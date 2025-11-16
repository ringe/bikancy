json.extract! station, :station_id, :name, :capacity, :bikes_available, :updated_at
json.url station_url(station, format: :json)
