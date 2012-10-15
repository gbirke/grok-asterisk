# This file reads the logfile "fullsmall" and prints something for every line
# where no grok pattern was found. This is for developing new patterns

require 'rubygems'
require 'grok-pure'
require 'pp'
require 'benchmark'

grok = Grok.new

grok.add_patterns_from_file("patterns/pure-ruby/base")
grok.add_patterns_from_file("patterns/pure-ruby/asterisk")

grok.compile("%{ASTLOG}")

# Check for content without a ASTCONTENT pattern from the library
# Ignore some of the uknown contents
def unparsed_content?(captures)
	content_types = [
		"ASTCONTENT_EXECUTE", 
		"ASTCONTENT_CHANNELJUMP", 
		"ASTCONTENT_GOTO",
		"ASTCONTENT_SIPCOSMARK", 
		"ASTCONTENT_PLAYAUDIO",
		"ASTCONTENT_DTMF",
		"ASTCONTENT_ASTMANAGER",
		"ASTCONTENT_CHANNELEVENT1",
		"ASTCONTENT_CHANNELEVENT2",
		"ASTCONTENT_CHANNELEVENT3",
		"ASTCONTENT_REGISTRATION_TIMEOUT",
		"ASTCONTENT_CONNECTION_REFUSED",
		"ASTCONTENT_SPAWN",
		"ASTCONTENT_UNKNOWN_SIPMESSAGE",
		"ASTCONTENT_INVALID_EXTENSION",
		"ASTCONTENT_QUEUE_EVENT",
		"ASTCONTENT_USERINPUT"
	]
	ignore = /Asterisk Queue Logger restarted|Remote UNIX connection|timeout set to|ignoring 'image' media offer|Broken pipe|MixMonitor close filestream|Found/
	return false if not captures['ASTCONTENT'].first  or ignore.match(captures['ASTCONTENT'].first)
	content_types.each { |c|
		return false if captures[c] != [nil] and captures[c] != []
	}
	return true
end

def process_line(line, grok)
	if line.strip != ""
		match = grok.match(line)
		if match
			if unparsed_content?(match.captures())
				#pp match.captures()
				#puts "\n"
				puts line
				
			end
		else
			puts "Unmatched line: #{line}"
			
		end
		return 1
	end
	return 0
end

File.open("fullsmall", "r") do |infile|
	lc = 0
	time = Benchmark.realtime do
		while (line = infile.gets)
			lc += process_line(line, grok)
		end
	end
	puts "#{lc} lines processed in #{time*1000} seconds"
end


