require 'rubygems'
require 'sqlite3'

  db = SQLite3::Database.new( "auto.db" )
  rows = db.execute( "select * from cars" )

puts rows