module SynchronizePostgresStoredProcedures
  module StoredProcedures
    class Synchronizer
      def initialize(connection)
        @connection = connection
      end

      delegate :select_one, :select_all, :execute, :select_value, :to => :@connection
      delegate :logger, :to => Pg
      delegate :pg_proc_columns, :to => :class

      def synchronize_all(procedures)
        procedures.sort_by(&:last).each do |source, name|
          synchronize(source, name)
        end
        sp_clean(procedures.map(&:last))
      end

      protected
      def synchronize(source, name)
        if(!(exists = sp_exists?(name)) || !sp_equal?(source, name))
          if exists
            logger.info "\t UPDATING: #{name}"
          else
            logger.info "\t CREATING: #{name}"
          end
          sp_drop(name)
          sp_create(name,source)
        else
          logger.info "\tunchanged: #{name} "
        end
      end

      protected
      def convert_arg(val)
        # select * from pg_type where typnamespace = 11 order by typname
        # look at typelem and typarray
        case val.to_i
        when 23 then 'integer'
        when 1007 then 'integer[]'
        when 25 then 'text'
        when 1043 then 'varchar(255)'
        when 1082 then 'date'
        when 1114 then 'timestamp'
        when 1184 then 'timestamptz'
        when 700 then 'pg_catalog.float4'
        when 701 then 'pg_catalog.float8'
        when 20 then 'bigint'
        when 1016 then 'bigint[]'
        when 16 then 'boolean'
        when 1186 then 'interval'
        else
          raise ArgumentError, "unknown argument type(#{val})"
        end
      end

      def temp_namespace_oid
        @temp_namespace_oid||=select_value("select oid from pg_namespace where nspname='temp'")
      end

      def namespace_for_oid(oid)
        select_value("select nspname from pg_namespace where oid=#{oid}")
      end

      def sp_create(name, source)
        execute(source)
        raise ::PG::Error, "failed to create stored procedure #{name} (check if the filename matches the function name) " if !sp_exists?(name)
      end

      def sp_equal?(source_string, name)
        sp_drop(name,temp_namespace_oid)
        sp_create(name, source_string.sub(/(.*CREATE(?: +OR +REPLACE)? +FUNCTION +)(\w+)(.*)/mi,"\\1temp.\\2\\3"))
        !select_one(%Q{select p1.proname from pg_proc p1, pg_proc p2
        where p1.proname = '#{name}' AND p1.pronamespace <> p2.pronamespace
              AND p2.proname = '#{name}' AND p2.pronamespace = #{temp_namespace_oid}
              AND regexp_replace(p1.prosrc,'\t','','g') = regexp_replace(p2.prosrc,'\t','','g')
              AND #{compare_columns_sql}}).nil?
      end

      def sp_exists?(name)
        select_one("select proname, pronamespace, proowner, proargtypes, prosrc from pg_proc where pronamespace = 2200 and proname='#{name}'").present?
      end

      # drops all functions of that name, even if they are overloaded.
      def sp_drop(name,oid=2200)
        select_all("select proname, pronamespace, proargtypes from pg_proc where pronamespace = #{oid} and proname='#{name}'").each do |hash|
          argtypes = hash["proargtypes"].split(' ').map {|val|convert_arg(val)}.join(",")
          name_with_schema="#{namespace_for_oid(oid)}.#{name}"
          execute("DROP FUNCTION IF EXISTS #{name_with_schema}(#{argtypes}) CASCADE")
        end
      end

      def sp_clean(stored_procedures)
        select_all("select proname, pronamespace, proowner, proargtypes, prosrc from pg_proc where proname like 'sp_%' and pronamespace = 2200").each do |results|
          unless stored_procedures.include?( results['proname'] )
            logger.info("\t DROPPING: #{results['proname']}")
            sp_drop( results['proname'] )
          end
        end
      end

      def compare_columns_sql
        pg_proc_columns.map {|col| "p1.#{col} IS NOT DISTINCT FROM p2.#{col}"}.join(" AND ")
      end

    end
  end
end
