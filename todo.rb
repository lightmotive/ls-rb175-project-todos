# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'
require './lists'

configure do
  enable :sessions
  set :session_secret, 'e243e641a34e345e6da8ef3584c4b68b194778d225e53dd103080c6a74f0b3a3'
  # TODO: A production app must not hard-code a secret like that; instead, retrieve from a secret management service.
  # Generated random key using the following code (see example: https://github.com/attr-encrypted/encryptor):
  # require 'securerandom'
  # SecureRandom.hex(32)
end

helpers do
  def list_edit_template
    erb :list_edit
  end
end

before '/list/:list_idx*' do
  @list_id = params[:list_idx].to_i
  @list = Lists.new(session)[@list_id]
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
  @lists = Lists.new(session).all
  erb :lists
end

# Render New List form
get '/lists/create' do
  erb :list_create
end

# Render list details (Todos)
get '/list/:list_idx' do
  erb :list
end

# Render list with Add Todo form
get '/list/:list_idx/add' do
  @add_todo = true
  erb :list
end

# Render list details with edit form
get '/list/:list_idx/edit' do
  @edit_list = true
  @list_name_value = @list[:name]
  erb :list
end

# Create new list
post '/lists' do
  list_name = params[:list_name]
  begin
    Lists.new(session).create(list_name) do |name_validated|
      session[:success] = "#{name_validated} created."
      redirect '/lists'
    end
  rescue ValidationError => e
    session[:error] = e.message
    @list_name_value = list_name
    erb :list_create
  end
end

# Update list details
post '/list/:list_idx' do
  list_name = params[:list_name]

  begin
    Lists.new(session).edit(@list_id, list_name) do
      session[:success] = 'List name updated.'
      redirect "/list/#{@list_id}"
    end
  rescue ValidationError => e
    session[:error] = e.message
    @list_name_value = list_name
    erb :list_edit
  end
end
