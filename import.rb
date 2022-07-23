require "rubygems"
require "nokogiri"
require "json"

FILES = [ ARGV[0] ]
ICONS = JSON.parse(IO.read("config/icons.json"))
TYPES = JSON.parse(IO.read("config/types.json"))

# the key order matters
# more specific categories are hit first, otherwise it can fall through to more generic icons
TAG_KEYS = ICONS.keys

class PlacesFilter < Nokogiri::XML::SAX::Document
	attr_accessor :osm_id
	attr_accessor :latitude
	attr_accessor :longitude
	attr_accessor :name
	attr_accessor :type
	attr_accessor :icon_carto
	attr_accessor :icon_fontawesome
	attr_accessor :tags
	
	def start_document
	end

	def start_element(element_name, element_attrs = [])
		attrs = element_attrs.to_h
		if element_name == "node"
			self.osm_id = attrs["id"]
			self.latitude = attrs["lat"]
			self.longitude = attrs["lon"]
			self.name = ""
			self.type = ""	
			self.icon_carto = ""	
			self.icon_fontawesome = ""	
			self.tags = []		
		elsif element_name == "tag"
			# just gather tag attributes here
			self.tags << attrs
		end
	end

	def end_element(element_name)
		if element_name == "node"
			# check for our keys in priority order
			for tag_k in TAG_KEYS
				# loop through found tags
				for attrs in self.tags
					k = attrs["k"]
					v = attrs["v"]
	
					if k == "name"
						self.name = v
					elsif k == tag_k
						# try to find an icon
						if self.icon_carto.length == 0
							# cuisine sometimes has multiple ;-separated values
							v = v.split(";").first
							if !ICONS[k][v].nil?
								self.icon_carto = "#{k}/#{v}"
								self.icon_fontawesome = ICONS[k][v]
							end
						end

						# also check types
						if self.type.length == 0
							if !TYPES[k].nil?
								if !TYPES[k][v].nil?
									self.type = v
								elsif !TYPES[k]["*"].nil?
									self.type = TYPES[k]["*"]
								end
							end
						end
					end
				end
			end
			
			if self.name.length > 0
				if self.icon_carto.length > 0
					s = "INSERT INTO places (osm_id, osm_type, name, latitude, longitude, pt, type, icon_carto, icon_fontawesome) VALUES ("
					s += "#{self.osm_id}, 'node', \"#{self.name}\", #{self.latitude}, #{self.longitude}, ST_GeomFromText('POINT(#{self.longitude} #{self.latitude})'), '#{self.type}', '#{self.icon_carto}', '#{self.icon_fontawesome}'"
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
