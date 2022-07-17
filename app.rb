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