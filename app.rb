Bundler.require

rom = ROM.container(:sql, ENV["DATABASE_URL"]) do |config|
	config.relation(:places) do
		schema(infer: true) do
			attribute :pt, ROM::Types::String
		end
		auto_struct true
	end
end

class Place < ROM::Repository[:places]
	def query(conditions)
		return places.where(conditions).to_a
	end
	
	def add(fields)
		places.insert([ fields ])
	end
end

db = Place.new(rom)

get "/" do
	return "Hello world."
end