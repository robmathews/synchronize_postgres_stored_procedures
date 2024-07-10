# frozen_string_literal: true

require 'spec_helper'
require 'synchronize_postgres_stored_procedures/stored_procedures/pg'

PROC=<<-SQL
  CREATE FUNCTION sp_foo(int) RETURNS integer AS $$
       SELECT $1 AS result;
  $$ LANGUAGE SQL;
SQL

RSpec.describe SynchronizePostgresStoredProcedures do
  it "has a version number" do
    expect(SynchronizePostgresStoredProcedures::VERSION).not_to be nil
  end
  let(:synchronizer) {
    SynchronizePostgresStoredProcedures::StoredProcedures::Pg.new.instance_variable_get(:@synchronizer)
  }
  describe 'convert_arg' do
    [23,1043,1082,700,701].each do |val|
      it "converts integer sp_arg types type=#{val}" do
        expect(synchronizer.send(:convert_arg, val)).to be_kind_of(String)
      end
    end
    it 'illegal value fails' do
      expect {synchronizer.send(:convert_arg, "illegal")}.to raise_error(ArgumentError)
    end
  end
  describe 'not-existing' do
    it 'is not there' do
      expect(synchronizer.send(:sp_exists?, "sp_foo")).to eq(false)
    end
  end

  it "raise error if name doesn't match source" do
    expect(synchronizer.send(:sp_create, "foo", PROC))
    raise "Did not raise expected exception"
  rescue => e
    unless e.kind_of?(::PG::Error)
      raise "Did not raise expected exception: #{e.class} expected (PG::Error)"
    end
  end

  describe 'existing' do
    before do
      synchronizer.send(:sp_create, "sp_foo", PROC)
    end

    it 'exists' do
      expect(synchronizer.send(:sp_exists?, "sp_foo")).to eq(true)
    end
    it 'drops' do
      synchronizer.send(:sp_drop, "sp_foo")
      expect(synchronizer.send(:sp_exists?, "sp_foo")).to eq(false)
    end
    it 'executes' do
      ActiveRecord::Base.connection.execute("select sp_foo(42)")
    end
    it 'cleans' do
      synchronizer.send(:sp_clean, ["foo"])
      expect(synchronizer.send(:sp_exists?, "sp_foo")).to eq(false)
    end
  end
end
