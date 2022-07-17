Bundler.require

db = Sequel.connect(ENV["DATABASE_URL"])

get "/" do
	@q = params[:q].to_s
	
	if @q.length > 0
		pieces = @q.split(",")
		lat = pieces.first.strip.to_f
		long = pieces.last.strip.to_f
		@places = db.fetch("SELECT * FROM places LIMIT 10")
	else
		@places = []
	end
	
	erb :index
end