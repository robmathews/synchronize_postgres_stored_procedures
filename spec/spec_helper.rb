# frozen_string_literal: true

require 'rspec'
require 'pg'
require 'rails'
require 'active_record'
require "synchronize_postgres_stored_procedures"
require "synchronize_postgres_stored_procedures/version"
require "synchronize_postgres_stored_procedures/stored_procedures.rb"


def drop_stored_procedure
  ActiveRecord::Base.connection.execute <<-SQL
    DROP FUNCTION IF EXISTS sp_foo(int);
  SQL
end

# Load database configuration
config = YAML.load_file(File.join(__dir__, 'database.yml'))
ActiveRecord::Base.establish_connection(config['test'])

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    drop_stored_procedure
  end
end
