module SynchronizePostgresStoredProcedures
  module StoredProcedures
    class Pg
      cattr_accessor :logger
      delegate :logger, :to => :class

      def initialize(connection = ActiveRecord::Base.connection)
        @connection = connection

        major,minor,point = get_version

        if (major < 9 || major > 16)
          raise "Unsupported postgres version #{get_version}"
        end

        @synchronizer = (
          case major
          when 12,13,14,15,16 then Pg12
          when 11 then Pg11
          else Pg9
          end
        ).new(@connection)

        # We want to write logs to the rails default logger and stdout
        loggers = [Logger.new(STDOUT)]
        loggers.append(Rails.logger) if Rails.logger
        self.logger = ActiveSupport::BroadcastLogger.new(*loggers)
      end

      def synchronize(directory = "db/sp")
        logger.info("Synchronizing stored procedures")

        dir = Dir.new(directory)
        stored_procedures = dir.entries.select {|f| f =~ /\.sql$/}

        @synchronizer.synchronize_all(stored_procedures.sort.map {|filename|
          [File.open(File.join(dir, filename)) { |f| f.read }, File.basename(filename, ".sql")]
        })
      end

      private
      def get_version
        version = @connection.select_one("SHOW server_version")['server_version']
        version.split('.').map(&:to_i)
      end
    end
  end
end

