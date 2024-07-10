module SynchronizePostgresStoredProcedures
  module StoredProcedures
    class Pg9 < Synchronizer
      def self.pg_proc_columns
        [
          "proowner",
          "prolang",
          "procost",
          "prorows",
          "provariadic",
          "protransform",
          "proisagg",
          "proiswindow",
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
