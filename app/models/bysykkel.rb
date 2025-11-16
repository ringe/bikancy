# # Bysykkel
#
# Query the Oslo Bysykkel API,
# see https://oslobysykkel.no/apne-data/sanntid
#
# Available instance methods come from config/initializers/gfbs_endpoints.rb
#
class Bysykkel
  include HTTParty
  base_uri "gbfs.urbansharing.com"

  def initialize(identifier = "ringe-bikancy")
    @options = {
      headers: {
        "Client-Identifier" => identifier,
        "User-Agent" => "Bikancy"
      },
      debug_output: STDOUT
    }
  end

  def get_file(gbfs_filename)
    self.class.get "/oslobysykkel.no/#{gbfs_filename}.json", @options
  end

  def method_missing(method_name, *args, &block)
    if GBFS_ENDPOINTS.include?(method_name.to_s)
      get_file(method_name)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    GBFS_ENDPOINTS.include?(method_name.to_s) || super
  end
end
