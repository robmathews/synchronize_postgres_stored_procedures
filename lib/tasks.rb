require "synchronize_postgres_stored_procedures/version"
require "synchronize_postgres_stored_procedures/stored_procedures.rb"

namespace :db do
  task :after_migrate do
    SynchronizePostgresStoredProcedures::StoredProcedures::Pg.new.synchronize
  end

  Rake::Task["db:migrate"].enhance do
    Rake::Task["db:after_migrate"].invoke
  end
end
