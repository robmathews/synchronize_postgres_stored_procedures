module SynchronizePostgresStoredProcedures
  module StoredProcedures
    class Pg12 < Synchronizer
      def self.pg_proc_columns
        [
          "proowner",
          "prolang",
          "procost",
          "prorows",
          "provariadic",
          "prosupport",
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

