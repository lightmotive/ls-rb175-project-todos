# frozen_string_literal: true

require_relative 'validate_all'
require_relative 'mocks'

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
        name: validate_name(name),
        todos: todos
      }

      data << list
      list
    end

    def [](id)
      list = data[id]
      raise ValidationError, "That list doesn't exist." if list.nil?

      list
    end

    def edit(id, name)
      list = self[id]
      list[:name] = validate_name(name, id: id)
      list
    end

    def delete(id)
      data.delete_at(id) if self[id]
    end

    private

    attr_reader :session

    def data
      session[:lists]
    end

    def list_names
      data.map { |list| list[:name] }
    end

    def list_names_except(id)
      list_names_except = list_names
      list_names_except.delete_at(id)
      list_names_except
    end

    def validate_name(name, id: nil)
      ValidateAll.do(
        name,
        [Validators::SanitizeWebUserInput,
         Validators::Strip,
         Validators::Length.new(1, 100, value_name: 'Name'),
         Validators::NotInCollection.new(
           id ? list_names_except(id) : list_names,
           'That list name exists. Please enter a unique name.'
         )]
      )
    end
  end
end
