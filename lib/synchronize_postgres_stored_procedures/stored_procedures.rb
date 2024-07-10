module SynchronizePostgresStoredProcedures
  module StoredProcedures
    require_relative 'stored_procedures/pg.rb'
    require_relative 'stored_procedures/synchronizer.rb'
    Dir[File.join(__dir__, 'stored_procedures', 'pg_*.rb')].each do |file|
      require file
    end
  end
end
