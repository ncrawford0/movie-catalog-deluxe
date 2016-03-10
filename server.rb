require "sinatra"
require "pg"
require "pry"

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/actors" do
  db_connection do |conn|
    query = "SELECT actors.id, actors.name FROM actors;"
    # binding.pry
    @actors = conn.exec(query).to_a
    erb :actors
  end
end

get "/actors/:id" do
  db_connection do |conn|
    query = "SELECT *
    FROM cast_members
    JOIN movies ON cast_members.movie_id = movies.id
    JOIN actors ON cast_members.actor_id = actors.id
    WHERE actors.id = '#{params[:id]}';"
    # binding.pry
    @characters = conn.exec(query).to_a
    erb :actor
  end
end

get "/movies" do
  db_connection do |conn|
    query = "SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
    FROM movies
    LEFT JOIN genres ON movies.genre_id = genres.id
    LEFT JOIN studios ON movies.studio_id = studios.id;"    # binding.pry
    @movies = conn.exec(query).to_a
    # binding.pry
    erb :movies
  end
end

get "/movies/:id" do
  db_connection do |conn|
    query = "SELECT movies.title, movies.year, movies.rating, actors.id as actor_id,
    genres.name AS genre, studios.name AS studio, cast_members.character,
    actors.name AS actor
    FROM cast_members
    JOIN movies ON cast_members.movie_id = movies.id
    LEFT JOIN actors ON cast_members.actor_id = actors.id
    LEFT JOIN genres ON movies.genre_id = genres.id
    LEFT JOIN studios ON movies.studio_id = studios.id
    WHERE movies.id = '#{params[:id]}';"
    @characters = conn.exec(query).to_a
    erb :movie
  end
end
