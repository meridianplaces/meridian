# Meridian

https://latl.ong/

Meridian works by loading a dump of OpenStreetMap places into MySQL. You can download global or region data from various OpenStreetMap mirrors. If downloading in .pbf format, use the tool `osmium` to extract data into .xml.

`import.rb` reads the .xml file and outputs SQL INSERT statements which can be fed into MySQL.

Example usage:

`$ ruby import.rb > places.sql`  
`$ mysqladmin -u root -p create meridian_dev`  
`$ mysql -u root -p meridian_dev < places.sql`  

To configure the web app, create a .env file with `DATABASE_URL=mysql2://...` using your database name and credentials. Run the web app with:

`$ bundle exec dotenv ruby app.rb`