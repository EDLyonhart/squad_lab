require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
require 'better_errors'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'sql_lab')

before do
  @conn = settings.conn
end

#ROOT ROUT
get '/' do
  redirect '/squads'
end

#SQUAD INDEX
  get '/squads' do
    squads = []
    @conn.exec("SELECT * FROM squads_table") do |results|
      results.each do |squad|
        squads << squad
      end
    end
    @squads = squads
    erb :index
  end

#NEW SQUAD
  get '/squads/new' do
    erb :squads_new
  end

#NEW STUDENT
  get '/squads/:squads_id/students/new' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])
    @squad = squad[0]

    erb :students_new
  end

#DISPLAY SQUAD INFO
  get '/squads/:squads_id' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])
    @squad = squad[0]

    erb :squad_show
  end

#SHOW EDIT SQUAD
  get '/squads/:squads_id/edit' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])

    erb :squad_edit
  end

#FULL SQUAD STUDENT INDEX
  get '/squads/:squads_id/students' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])
    @squad = squad[0]

    students = []
    @conn.exec("SELECT * FROM students_table") do |result|
      result.each do |student|
        students << student
      end
    end

    @students = students
    erb :students_index
  end

#SHOW INFO ABOUT A STUDENT
get '/squads/:id/students/:id' do
  id = params[:squads_id].to_i
  squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])
  @squad = squad[0]

  id = params[:id]
  student = @conn.exec("SELECT * FROM students_table WHERE id = $1", [id])
  @student = student[0]
  erb :student_show
end

# SHOW EDIT STUDENT
  get '/squads/:id/students/:id/edit' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])
    @squad = squad[0]

    id = params[:id].to_i
    student = @conn.exec("SELECT * FROM students_table WHERE id = $1", [params[:id].to_i])
    @student = student[0]
    erb :student_edit
  end







#CREATE STUDENT
  post '/squads/:id/students' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])

    name = params[:name]
    age = params[:age].to_i
    spirit_animal = params[:spirit_animal]
    @conn.exec("INSERT INTO students_table (name, age, spirit_animal, squad_id) VALUES ($1, $2, $3, $4)", [name, age, spirit_animal, id])
    redirect '/squads/:squads_id/students'
  end

#CREATE SQUAD
post '/squads' do
  name = params[:name]
  mascot = params[:mascot]
  @conn.exec("INSERT INTO squads_table (name, mascot) VALUES ($1, $2)", [name, mascot])
  redirect '/squads'
end






#EDIT SQUAD
  put '/squads/:id' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])

    name = params[:name]
    mascot = params[:mascot]
    id = params[:squads_id]
    @conn.exec("UPDATE squads_table SET name=$1 WHERE squads_id=$2", [name, id])
    @conn.exec("UPDATE squads_table SET mascot=$1 WHERE squads_id=$2", [mascot, id])
    redirect '/squads'
  end

#EDIT STUDENT
  put '/squads/:squads_id/students/:id' do
    id = params[:squads_id].to_i
    squad = @conn.exec("SELECT * FROM squads_table WHERE squads_id = $1", [id])

    name = params[:name]
    age = params[:age].to_i
    spirit_animal = params[:spirit_animal]
    @conn.exec("UPDATE students_table SET name=$1 WHERE id=$2", [name, id])
    @conn.exec("UPDATE students_table SET age=$1 WHERE id=$2", [age, id])
    @conn.exec("UPDATE students_table SET spirit_animal=$1 WHERE id=$2", [spirit_animal, id])

    redirect '/squads/:squads_id'
  end












