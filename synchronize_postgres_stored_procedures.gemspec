# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "lib/synchronize_postgres_stored_procedures/version"

Gem::Specification.new do |spec|
  spec.name = "synchronize_postgres_stored_procedures"
  spec.version = SynchronizePostgresStoredProcedures::VERSION
  spec.authors = ["rob mathews"]
  spec.email = ["rob@justsoftwareconsulting.com"]

  spec.summary = "Maintain your stored procedures in a single file per procedure, not spread across multiple migrations"
  spec.homepage = "https://github.com/robmathews/synchronize_postgres_stored_procedures"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/robmathews/synchronize_postgres_stored_procedures"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'pg'
end
