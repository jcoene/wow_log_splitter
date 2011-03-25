require "rubygems"
require "active_record"
require "yaml"
require "time"
require "date"
require "stringio"

require "lib.rb"
require "config.rb"
require "wow.rb"

log = Wow::Logfile.new("test2.log")


str = '"Hello there"'
print "%s\n" % str
print "%s\n" % str.unquote
print "%s\n" % str

start = Time.now
n=0
log.events do |e|
	n += 1
	#break if n > 100
	print "%s\n" % e.to_sql
end

done = Time.now
sec = (done-start).ceil
persec = (n/sec).ceil

p "Processed %d lines in %d sec, %d lines/sec" % [n, sec, persec]