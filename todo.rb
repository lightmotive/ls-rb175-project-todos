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

helpers do
  # TODO: refactor the following helper logic to a module to be included here
  # (`helpers TodoApp::Helpers::ListHelpers`).
  # - That's important to minimize multiple "queries against a database" during
  #   rendering; good conceptual practice for production implementations.
  # - Instead of passing list id to methods below, pass a list object
  #   (includes todos). Then:
  #   - Views can pass a list object to helper method.
  #   - Reuse the logic in Lists and Todos where already implemented as follows:
  #     1. Require the module in the class file.
  #     2. Implement appropriately named methods with list_id param.
  #     3. Retrieve the list by ID, then pass the list to the associated module
  #        method. Return the module method's value.
  def todos_count(list_id)
    TodoApp::Todos.new(session, list_id).count
  end

  def todos_count_by_done(list_id:, done:)
    TodoApp::Todos.new(session, list_id).count_by_done(done)
  end

  def list_has_todos(list_id)
    todos_count(list_id).positive?
  end

  def list_complete?(list_id)
    todos_count_not_done = todos_count_by_done(list_id: list_id, done: false)
    list_has_todos(list_id) && todos_count_not_done.zero?
  end

  def list_completable?(list_id)
    return false unless list_has_todos(list_id)

    todos_count_not_done = todos_count_by_done(list_id: list_id, done: false)
    todos_count_not_done.positive?
  end

  def list_class(list_id)
    'complete' if list_complete?(list_id)
  end
end

# Validate list ID and retrieve list
before %r{/lists/(-?\d+)(?:/?.*)} do
  @list_id = params['captures'].first.to_i

  @list = Steps.process(
    action: proc { TodoApp::Lists.new(session)[@list_id] },
    on_success: proc { |list| list },
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      redirect '/lists'
    end
  )
end

# Validate todo ID and retrieve todo
before %r{/lists/(?:-?\d+)/todos/(-?\d+)(?:/?.*)} do
  @todo_id = params['captures'].first.to_i

  @todo = Steps.process(
    action: proc { TodoApp::Todos.new(session, @list_id)[@todo_id] },
    on_success: proc { |todo| todo },
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      redirect "/lists/#{@list_id}"
    end
  )
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
  Steps.process(
    action: proc { TodoApp::Lists.new(session).create(params[:list_name]) },
    on_success: proc do |list|
      session[:success] = "#{list[:name]} created."
      redirect '/lists'
    end,
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      erb :list_create
    end
  )
end

# Update existing list
post '/lists/:list_id' do
  Steps.process(
    action: proc { TodoApp::Lists.new(session).edit(@list_id, params[:list_name]) },
    on_success: proc do |_list|
      session[:success] = 'List name updated.'
      redirect "/lists/#{@list_id}"
    end,
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      erb :list_edit
    end
  )
end

# Delete list
post '/lists/:list_id/delete' do
  Steps.process(
    action: proc { TodoApp::Lists.new(session).delete(@list_id) },
    on_success: proc do |list|
      session[:success] = "#{list[:name]} list was deleted."
      redirect '/lists'
    end,
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      erb :list_edit
    end
  )
end

# Mark complete all todos on a list
post '/lists/:list_id/complete' do
  Steps.process(
    action: proc { TodoApp::Lists.new(session).set_todos_done(@list_id, true) },
    on_success: proc do |list|
      session[:success] = "#{list[:name]} list was completed."
      redirect "/lists/#{@list_id}"
    end,
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      erb :list
    end
  )
end

# Add a Todo to a list
post '/lists/:list_id/todos' do
  Steps.process(
    action: proc { TodoApp::Todos.new(session, @list_id).create(params[:todo_name]) },
    on_success: proc do |_list|
      session[:success] = 'Todo was added.'
      redirect "/lists/#{@list_id}"
    end,
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      erb :list
    end
  )
end

# Delete Todo from a list
post '/lists/:list_id/todos/:todo_id/delete' do
  Steps.process(
    action: proc { TodoApp::Todos.new(session, @list_id).delete(@todo_id) },
    on_success: proc do |_todo|
      session[:success] = 'Todo was deleted.'
      redirect "/lists/#{@list_id}"
    end,
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      erb :list
    end
  )
end

# Toggle Todo "done" status (check/mark)
post '/lists/:list_id/todos/:todo_id/check' do
  mark_value = (params['done'] == 'true')
  Steps.process(
    action: proc { TodoApp::Todos.new(session, @list_id).mark(@todo_id, done: mark_value) },
    on_success: proc do |_todo|
      redirect "/lists/#{@list_id}"
    end,
    on_failure: proc do |messages|
      session[:error] = messages.as_html
      erb :list
    end
  )
end
