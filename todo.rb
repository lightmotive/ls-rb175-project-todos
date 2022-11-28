# frozen_string_literal: true

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'
require './todo_app/lists'
require './todo_app/todos'
require './todo_app/view_helpers/list'
require './todo_app/view_helpers/lists'
require './todo_app/view_helpers/todos'

configure do
  enable :sessions
  set :session_secret, 'e243e641a34e345e6da8ef3584c4b68b194778d225e53dd103080c6a74f0b3a3'
  # TODO: A production app must not hard-code a secret like that; instead, retrieve from a secret management service.
  # Generated random key using the following code (see example: https://github.com/attr-encrypted/encryptor):
  # require 'securerandom'
  # SecureRandom.hex(32)
end

helpers TodoApp::ViewHelpers::List, TodoApp::ViewHelpers::Lists

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

# Specific List
namespace %r{/lists/(?<list_id>-?\d+)} do
  helpers TodoApp::ViewHelpers::Todos

  # Validate list ID and retrieve list
  before do
    @list_id = params[:list_id].to_i

    @list = Steps.process(
      action: proc { TodoApp::Lists.new(session)[@list_id] },
      on_success: proc { |list| list },
      on_failure: proc do |messages|
        session[:error] = messages.as_html
        redirect '/lists'
      end
    )
  end

  # Render list details (Todos)
  get do
    erb :list
  end

  # Render list edit form
  get '/edit' do
    erb :list_edit
  end

  # Update existing list
  post do
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
  post '/delete' do
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

  # Set all todos to done
  post '/complete' do
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
  post '/todos' do
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

  # Specific Todo in a list (nested within namespace: %r{/lists/(-?\d+)})
  namespace %r{/todos/(?<todo_id>-?\d+)} do
    # Validate todo ID and retrieve todo
    before do
      @todo_id = params[:todo_id].to_i

      @todo = Steps.process(
        action: proc { TodoApp::Todos.new(session, @list_id)[@todo_id] },
        on_success: proc { |todo| todo },
        on_failure: proc do |messages|
          session[:error] = messages.as_html
          redirect "/lists/#{@list_id}"
        end
      )
    end

    # Delete Todo from a list
    post '/delete' do
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
    post '/check' do
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
  end
end
