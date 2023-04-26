Bundler.require

db = Sequel.connect(ENV["DATABASE_URL"])

ICONS = JSON.parse(IO.read("config/icons.json"))
TYPES = JSON.parse(IO.read("config/types.json"))

get "/" do
	@q = params[:q].to_s
	
	if @q.length > 0
		pieces = @q.split(",")
		lat = pieces.first.strip.to_f
		long = pieces.last.strip.to_f
		sql = "SELECT id, name, type, icon_fontawesome, ST_AsText(pt), ST_Distance_Sphere(pt, ST_GeomFromText('POINT(#{long} #{lat})')) AS meters FROM places HAVING meters < 100000 ORDER BY meters LIMIT 50"
		@places = db.fetch(sql)
	else
		@places = []
	end
	
	erb :index
end

get "/places/types" do
	content_type :json
	
	flat_list = []
	
	TYPES.each do |key, val|
		val.each do |sub_key, sub_val|
			flat_list << sub_val
		end
	end
	
	flat_list.uniq!
	return flat_list.to_json
end

get "/places/icons" do
	content_type :json

	flat_list = []
	
	ICONS.each do |key, val|
		val.each do |sub_key, sub_val|
			flat_list << sub_val
		end
	end
	
	flat_list.uniq!
	return flat_list.to_json
end

get "/places/nearby" do
	content_type :json

	lat = params[:latitude].to_f
	long = params[:longitude].to_f
	meters = params[:meters] || 10000
	count = params[:count] || 50
	app_source = params[:app_source]
	
	if app_source.nil?
		sql = "SELECT id, osm_id, name, type, icon_carto, icon_fontawesome, latitude, longitude, ST_Distance_Sphere(pt, ST_GeomFromText('POINT(#{long} #{lat})')) AS meters FROM places HAVING meters < #{meters.to_i} ORDER BY meters LIMIT #{count.to_i}"
		places = db.fetch(sql)
	else
		sql = "SELECT id, osm_id, name, type, icon_carto, icon_fontawesome, latitude, longitude, ST_Distance_Sphere(pt, ST_GeomFromText('POINT(#{long} #{lat})')) AS meters FROM places WHERE app_source = ? HAVING meters < #{meters.to_i} ORDER BY meters LIMIT #{count.to_i}"
		places = db.fetch(sql, app_source)
	end
	
	results = []
	for place in places
		tags = [
			place[:type], 
			place[:icon_fontawesome],
			place[:icon_carto].split("/").first,
			place[:icon_carto].split("/").last
		]
		results << {
			id: place[:id],
			osm_id: place[:osm_id],
			name: place[:name],
			type: place[:type],
			icon_carto: place[:icon_carto],
			icon_fontawesome: place[:icon_fontawesome],
			latitude: place[:latitude],
			longitude: place[:longitude],
			tags: tags.uniq
		}
	end
	
	return JSON.pretty_generate(results)
end

post "/places" do
	content_type :json

	name = params[:name].to_s
	type = params[:type].to_s
	lat = params[:latitude].to_f
	long = params[:longitude].to_f
	app_source = params[:app_source].to_s
	app_name = params[:app_name].to_s
	
	if name.length > 0	
		insert_ds = db["INSERT INTO places (osm_id, osm_type, name, type, latitude, longitude, pt, app_source, app_name) VALUES (?, ?, ?, ?, ?, ?, ST_GeomFromText('POINT(#{long} #{lat})'), ?, ?)", 0, "", name, type, lat, long, app_source, app_name]
		insert_ds.insert
	end
	
	info = {}
	return info.to_json
end