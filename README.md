# SynchronizePostgresStoredProcedures

Don't want to track down multiple versions of a stored procedure across
multiple migrations to find the current source? Want to just edit a file
and have the stored procedure (or function) be automatically updated
in your database as part of the db:migrate step? Then this gem is
for you.

Given a directory of stored procedures, it will add, update, and drop the sp's in the database to match the directory on disk.

## The Rules
The rules are simple:

* install the gem as directed below
* put each stored procedure in it's own file (see below for example) in the db/sp directory.
* all your stored procedures must start with the name 'sp_'. This is to prevent conflict with existing postgres stored procedures.
* the stored procedures will be installed alphabetically, so if you have one sp that depends on another sp, be sure the other sp comes first alphabetically.

### Example

Say you have this function, called 'sp_unaccent', as below:
```sql
CREATE OR REPLACE FUNCTION sp_unaccent(text)
  RETURNS text AS
$func$
SELECT public.unaccent('public.unaccent', $1)  -- schema-qualify function and dictionary. Modifies public version to be IMMUTABLE so it can be indexed.
$func$  LANGUAGE sql IMMUTABLE;
```
Place that text in the file db/sp/sp_unaccent.sql, and this gem will ensure that the sp is up to date in any database that the migrations are applied to.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'synchronize_postgres_stored_procedures'
```
Execute
```sh
 bundle install
```
## Usage
Run 'rake db:migrate' as usual, the gem will automatically be invoked.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
To run the tests:
```sh
createdb synchronize_postgres_stored_procedures_test
bundle exec rake spec
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robmathews/synchronize_postgres_stored_procedures. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/robmathews/synchronize_postgres_stored_procedures/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SynchronizePostgresStoredProcedures project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/robmathews/synchronize_postgres_stored_procedures/blob/main/CODE_OF_CONDUCT.md).
