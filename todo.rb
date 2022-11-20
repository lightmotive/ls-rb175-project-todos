require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

def lists
  [
    { name: 'Lunch Groceries', todos: [] },
    { name: 'Dinner Groceries', todos: [] }
  ]
end

get '/' do
  redirect '/lists'
end

get '/lists' do
  @lists = lists
  erb :lists
end
