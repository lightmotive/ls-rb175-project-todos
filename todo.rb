# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'
require './todo_app/lists'
require './todo_app/todos'

configure do
  enable :sessions
  set :session_secret, 'e243e641a34e345e6da8ef3584c4b68b194778d225e53dd103080c6a74f0b3a3'
  # TODO: A production app must not hard-code a secret like that; instead, retrieve from a secret management service.
  # Generated random key using the following code (see example: https://github.com/attr-encrypted/encryptor):
  # require 'securerandom'
  # SecureRandom.hex(32)
end

before %r{/lists/(\d+)(?:/?.*)} do
  @list_id = params['captures'].first.to_i

  @list = TodoApp::Lists.new(session)[@list_id]
  if @list.nil?
    session[:error] = 'List not found.'
    redirect '/lists'
  end
end

get '/' do
  redirect '/lists'
end

# Render list of lists
get '/lists' do
  @lists = TodoApp::Lists.new(session).all
  erb :lists
end

# Render New List form
get '/lists/create' do
  erb :list_create
end

# Render list details (Todos)
get '/lists/:list_id' do
  erb :list
end

# Render list edit form
get '/lists/:list_id/edit' do
  erb :list_edit
end

# Create new list
post '/lists' do
  list_name = params[:list_name]
  begin
    list = TodoApp::Lists.new(session).create(list_name)
    session[:success] = "#{list[:name]} created."
    redirect '/lists'
  rescue TodoApp::ValidationErrors => e
    session[:error] = e.messages_as_html
    erb :list_create
  end
end

# Update existing list
post '/lists/:list_id' do
  TodoApp::Lists.new(session).edit(@list_id.to_i, params[:list_name])
  session[:success] = 'List name updated.'
  redirect "/lists/#{@list_id}"
rescue TodoApp::ValidationErrors => e
  session[:error] = e.messages_as_html
  erb :list_edit
end

# Delete list
post '/lists/:list_id/delete' do
  TodoApp::Lists.new(session).delete(@list_id.to_i)
  session[:success] = "#{@list[:name]} list was deleted."
  redirect '/lists'
rescue TodoApp::ValidationErrors => e
  session[:error] = e.messages_as_html
  erb :list_edit
end

# Add a Todo to a list
post '/lists/:list_id/todos' do
  TodoApp::Todos.new(session, @list_id.to_i).create(params[:todo_name])
  session[:success] = 'Todo was added.'
  redirect "/lists/#{@list_id}"
rescue TodoApp::ValidationErrors => e
  session[:error] = e.messages_as_html
  erb :list
end
