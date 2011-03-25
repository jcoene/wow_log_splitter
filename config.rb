ActiveRecord::Base.logger = Logger.new(STDERR)

ActiveRecord::Base.establish_connection(
				:adapter => 'mysql',
				:database => 'loggy',
				:username => 'loggy',
				:password => 'loggy',
				:host => 'localhost')
