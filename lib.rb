
class String
  def unquote
    self.gsub(/^"(.*?)"$/,'\1')
	end
	def quote
		"\"%s\"" % self
	end
end

def Time.parse_wow(str)
	/(\d{1,2})\/(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,3})/ =~ str
	month, day, hour, min, sec, usec = $~[1..6]
	Time.local(Time.now.year, month, day, hour, min, sec, usec)
end