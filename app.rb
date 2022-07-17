Bundler.require

db = Sequel.connect(ENV["DATABASE_URL"])

get "/" do
	@q = params[:q].to_s
	
	if @q.length > 0
		pieces = @q.split(",")
		lat = pieces.first.strip.to_f
		long = pieces.last.strip.to_f
		sql = "SELECT id, name, type, icon, ST_AsText(pt), ST_Distance_Sphere(pt, ST_GeomFromText('POINT(#{long} #{lat})')) AS meters FROM places HAVING meters < 100000 ORDER BY meters LIMIT 50"
		@places = db.fetch(sql)
	else
		@places = []
	end
	
	erb :index
end

get "/places/nearby" do
	content_type :json

	lat = params[:latitude].to_f
	long = params[:longitude].to_f
	meters = params[:meters] || 10000
	count = params[:count] || 50
	
	sql = "SELECT id, osm_id, name, type, icon, latitude, longitude, ST_Distance_Sphere(pt, ST_GeomFromText('POINT(#{long} #{lat})')) AS meters FROM places HAVING meters < #{meters.to_i} ORDER BY meters LIMIT #{count.to_i}"
	places = db.fetch(sql)
	
	results = []
	for place in places
		results << {
			id: place[:id],
			osm_id: place[:osm_id],
			name: place[:name],
			type: place[:type],
			icon: place[:icon],
			latitude: place[:latitude],
			longitude: place[:longitude]
		}
	end
	
	return JSON.pretty_generate(results)
end