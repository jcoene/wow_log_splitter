
require "wow_const.rb"

class Wow

	class Logfile
	
		def initialize(filename)
			@filename = filename
		end
		
		def events
			File.open(@filename, "r") do |f|
				while (line = f.gets)
					e = Wow::Event.new
					e.parse(line)
					yield e
				end
			end
		end
		
	end
	
	
	class Event < ActiveRecord::Base
		attr_accessor :raw, :time, :event, :source, :dest, :spell
		
		def to_s; @raw; end
		
		def parse(str)
			r = str.split(",")
			time, event = r[0].split("  ")
			
			@raw = str
			@time = Time.parse_wow(time)
			
			event = "SPELL_DAMAGE" if event == "DAMAGE_SHIELD" or event == "DAMAGE_SPLIT"
			event = "SPELL_MISSED" if event == "DAMAGE_SHIELD_MISSED"
			
			@event = event
			
			@source = Wow::Unit.new(r[2].unquote, r[1], r[3].to_i(16))
			@dest = Wow::Unit.new(r[5].unquote, r[4], r[6].to_i(16))
			
			case @event
				when /^SP/, /^RA/
					@spell = Wow::Spell.new(r[8].unquote, r[7].to_i, r[9].to_i(16))
					@params = r[10..-1]
				when /^SW/
					@spell = Wow::Spell.new("melee", 0, SCHOOL_PHYSICAL)
					@params = r[7..-1]
				when /^EN/
					@spell = Wow::Spell.new(r[7], 0, SCHOOL_PHYSICAL)
					@params = r[8..-1]
			end
		end
		
		def amount; @params[0].to_i; end
		def overkill; @params[1].to_i; end
		def resisted; @params[3].to_i; end
		def blocked; @params[4].to_i; end
		def absorbed; @event =~ /_DAMAGE$/ ? @params[5].to_i : @params[2].to_i; end
		def critical; @event =~ /_DAMAGE$/ ? @parmas[6].to_i : @params[3].to_i; end
		def glancing?; @params[7]==1; end
		def crushing?; @params[8]==1; end
		
		def type
			case @event
				when /_ENERGIZE$/, /_DRAIN$/, /_LEECH$/
					@params[1]
				when /_AURA_BROKEN_SPELL$/, /_DISPEL$/, /_STOLEN$/
					@params[3]
				when /_MISSED$/, /_AURA_/, /_CAST_FAILED$/
					@params[0]
			end
		end
		
		def extraspell
			case @event
				when /_INTERRUPT$/, /_DISPEL/, /_STOLEN$/, /_AURA_BROKEN_SPELL$/
					Wow::Spell.new(@params[1], @params[0].to_i, @params[2].to_i(16))
			end
		end
		
		def extraamount
			case @event
				when /_DRAIN$/, /_LEECH$/
					@params[2]
			end
		end
		
		def to_sql
			sql = "INSERT INTO `events` ("
			sql << [ @time.to_i, @event.quote, @source.to_s.quote, @dest.to_s.quote, @spell.to_s.quote ].join(",")
			sql << ") VALUES ("
			sql << [ @time, @event, @source, @dest, @spell, @params ].join(",")
			sql << ")"
		end
		
	end
	
	class Unit
		attr_reader :name, :guid, :flags
		
		def to_i; self.id; end
		def to_s; @name; end
		
		def initialize(name, guid, flags)
			@name, @guid, @flags, = name, guid, flags
		end
		
		def id; self.npc? ? @guid[8..11].to_i(16) : 0; end
		
		def exists?; not @guid == UNIT_GUID_NONE; end
		def player?; (@flags & OBJECT_TYPE_MASK) == OBJECT_TYPE_PLAYER; end
		def pet?; (@flags & OBJECT_TYPE_MASK) == OBJECT_TYPE_PET; end
		def npc?; (@flags & OBJECT_TYPE_MASK) == OBJECT_TYPE_NPC; end
		def friendly?; (@flags & OBJECT_REACTION_MASK) == OBJECT_REACTION_FRIENDLY; end
		def hostile?; (@flags & OBJECT_REACTION_MASK) == OBJECT_REACTION_HOSTILE; end
		def neutral?; (@flags & OBJECT_REACTION_MASK) == OBJECT_REACTION_FRIENDLY; end
		
	end
	
	class Spell
		attr_reader :id, :name
		
		def to_i; @id; end
		def to_s; @name; end
		
		def initialize(name, id, school)
			@name, @id, @school = name, id, school
		end
		
		
		def school
			case @school
				when SCHOOL_PHYSICAL
					"physical"
				when SCHOOL_HOLY
					"holy"
				when SCHOOL_FIRE
					"fire"
				when SCHOOL_NATURE
					"nature"
				when SCHOOL_FIRESTORM
					"firestorm"
				when SCHOOL_FROST
					"frost"
				when SCHOOL_FROSTFIRE
					"frostfire"
				when SCHOOL_FROSTSTORM
					"froststorm"
				when SCHOOL_SHADOW
					"shadow"
				when SCHOOL_SHADOWSTORM
					"shadowstorm"
				when SCHOOL_SHADOWFROST
					"shadowfrost"
				when SCHOOL_ARCANE
					"arcane"
				when SCHOOL_SPELLFIRE
					"spellfire"
				else
					"physical"
			end
		end
		
	end
end
