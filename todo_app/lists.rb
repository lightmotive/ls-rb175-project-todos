# frozen_string_literal: true

require 'random/formatter'
require_relative 'mocks'
require './steps_lib/steps'

module TodoApp
  # Session-based Lists Data Access Object.
  class Lists
    def initialize(session = TodoApp::Mocks::SESSION)
      @session = session
      session[:lists] ||= []
    end

    def all
      data
    end

    def create(name, todos = [])
      list = {
        id: Random.uuid,
        name: validate_name(name),
        todos: todos
      }

      data << list
      list
    end

    def [](id)
      # Acknowledgement: this isn't a performant data store; a production app
      # would use a database for efficient lookup by unique ID.
      # For practice purposes, this is sufficient.
      Steps.one_step_process(get_by_id(id)) do |list, step|
        list.nil? ? step.throw_failure("That list doesn't exist.") : list
      end
    end

    def edit(id, name)
      list = self[id]
      list[:name] = validate_name(name, id: id)
      list
    end

    def set_todos_done(id, done)
      list = self[id]
      todos = list[:todos]
      todos.each { |todo| todo[:done] = done }
      list
    end

    def delete(id)
      data.delete_if { |list| list[:id] == id } if self[id]
    end

    private

    attr_reader :session

    def data
      session[:lists]
    end

    def exist?(id)
      get_by_id(id).nil?
    end

    def get_by_id(id)
      data.select { |list| list[:id] == id }.first
    end

    def list_names
      data.map { |list| list[:name] }
    end

    def list_names_except(list_id)
      list = get_by_id(list_id)
      return list_names if list.nil?

      list_names_except = list_names
      list_names_except.delete(list[:name])
      list_names_except
    end

    def validate_name(name, id: nil)
      Steps::Sequence.new(
        [Steps::Common::SanitizeWebUserInput,
         Steps::Common::Strip,
         Steps::Common::EnsureLengthBetween.new(1, 100, value_name: 'Name'),
         Steps::Common::EnsureNotInCollection.new(
           id ? list_names_except(id) : list_names,
           'That list name exists. Please enter a unique name.'
         )]
      ).process(name)
    end
  end
end
