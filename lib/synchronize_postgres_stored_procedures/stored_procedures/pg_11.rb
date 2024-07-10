module SynchronizePostgresStoredProcedures
  module StoredProcedures
    class Pg11 < Synchronizer
      def self.pg_proc_columns
        [
          "proowner",
          "prolang",
          "procost",
          "prorows",
          "provariadic",
          "protransform",
          "prokind",
          "prosecdef",
          "proleakproof",
          "proisstrict",
          "proretset",
          "provolatile",
          "pronargs",
          "pronargdefaults",
          "prorettype",
          "proargtypes",
          "proallargtypes",
          "proargmodes",
          "proargnames",
          "proargdefaults",
          "probin",
          "proconfig",
          "proacl"
        ]
      end
    end
  end
end

