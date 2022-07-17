require "rubygems"
require "nokogiri"
require "json"

FILES = [ ARGV[0] ]
ICONS = JSON.parse(IO.read("icons.json"))

# the key order matters
# more specific categories are hit first, otherwise it can fall through to more generic icons
TAG_KEYS = ICONS.keys

class PlacesFilter < Nokogiri::XML::SAX::Document
	attr_accessor :osm_id
	attr_accessor :latitude
	attr_accessor :longitude
	attr_accessor :name
	attr_accessor :icon
	
	def start_document
	end

	def start_element(element_name, element_attrs = [])
		attrs = element_attrs.to_h
		if element_name == "node"
			self.osm_id = attrs["id"]
			self.latitude = attrs["lat"]
			self.longitude = attrs["lon"]
			self.name = ""
			self.icon = ""			
		elsif element_name == "tag"
			# loop through our tag keys in order
			for tag_k in TAG_KEYS
				# see if we have a found on the current tag
				k = attrs["k"]
				v = attrs["v"]
				if k == "name"
					self.name = v
				elsif !ICONS[tag_k][v].nil?
					if icon.length == 0
						self.icon = ICONS[tag_k][v]
					end
				end
			end			
		end
	end

	def end_element(element_name)
		if element_name == "node"
			if self.name.length > 0
				if self.icon.length > 0
#					puts "#{self.osm_id}: #{self.latitude}, #{self.longitude}: #{self.name} (icon: #{self.icon})"
					s = "INSERT INTO places (osm_id, osm_type, name, latitude, longitude, pt, type, icon) VALUES ("
					s += "#{self.osm_id}, 'node', \"#{self.name}\", #{self.latitude}, #{self.longitude}, ST_GeomFromText('POINT(#{self.longitude} #{self.latitude})'), '', '#{self.icon}'"
					s += ");"
					puts s
				else
#					puts "#{self.osm_id}: No icon: #{self.name}"
				end
			end
		end
	end

	def end_document
	end
end

for f in FILES
	parser = Nokogiri::XML::SAX::Parser.new(PlacesFilter.new)
	parser.parse(File.open(f))
end
