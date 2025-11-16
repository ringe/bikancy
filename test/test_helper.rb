ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |file| require file }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup fixtures only for tables present in the test database.
    begin
      if ActiveRecord::Base.connected?
        fixture_files = Dir[Rails.root.join("test/fixtures/*.yml")]
        available_tables = fixture_files.filter_map { |path| File.basename(path, ".yml") }
        existing_fixtures = available_tables.select do |table_name|
          ActiveRecord::Base.connection.data_source_exists?(table_name)
        end
        fixtures(*existing_fixtures.map(&:to_sym)) if existing_fixtures.any?
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      # Ignore missing database errors during tests that rely solely on stubs.
    end

    # Add more helper methods to be used by all tests here...
  end
end
