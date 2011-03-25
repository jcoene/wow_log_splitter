#x = /^(\d{1,2})\/(\d{1,2})/ =~ "4/14 21:55:03.183"
x = /(\d{1,2})\/(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,3})/ =~ "4/14 21:55:03.183"
month, day, hour, min, sec, usec = $~[1..-1]


	class Time << Time
		attr_accessor :year, :month, :day, :hour, :min, :sec, :usec
		
		def initialize(str)
			/(\d{1,2})\/(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,3})/ =~ str
			@month, @day, @hour, @min, @sec, @usec = $~[1..6]
			@year = Time.now.year if not @year
		end
		
		def to_s
			"%4d/%2d/%2d %2d:%2d:%2d.%3d" % [@year, @month, @day, @hour, @min, @sec, @usec]
		end
		
		def to_i
			Time.parse(self.to_s).to_i
		end
	end
	