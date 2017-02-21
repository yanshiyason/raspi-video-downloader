# Open a database
db = SQLite3::Database.new "youtube.db"
# Create a table
rows = db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS videos (
    id integer,
    video_title varchar(90)
  );
SQL

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => "youtube.db"
)
