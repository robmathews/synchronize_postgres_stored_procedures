module SynchronizePostgresStoredProcedures
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks.rb"
    end
  end
end
