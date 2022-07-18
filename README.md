# Meridian

https://latl.ong/

Meridian works by loading a dump of OpenStreetMap places into MySQL. You can download global or region data from various OpenStreetMap mirrors. If downloading in .pbf format, use the tool `osmium` to extract data into .xml.

For example, given a file `north-america-latest.osm.pbf`, to extract roughly the Austin, Texas area to a new file:

`$ osmium extract -b -98.0956,30.0489,-97.2963,30.5244 north-america-latest.osm.pbf -o austin.xml`

`import.rb` reads the .xml file and outputs SQL INSERT statements which can be fed into MySQL.

Make sure to install Ruby version 2.7.6 and run `bundle install` to get things set up.

Example usage:

`$ bundle exec ruby import.rb austin.xml > places.sql`  
`$ mysqladmin -u root -p create meridian_dev`  
`$ mysql -u root -p meridian_dev < places.sql`  

To configure the web app, create a `.env` file with `DATABASE_URL=mysql2://...` using your database name and credentials. Run the web app with:

`$ bundle exec dotenv ruby app.rb`

Place icons use Font Awesome. You can add `FONTAWESOME_URL=` to your `.env` file to specify a Kit JS URL.