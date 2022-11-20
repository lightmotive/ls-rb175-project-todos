# frozen_string_literal: true

class Lists
  def initialize(session = { lists: [] })
    @session = session
    session[:lists] ||= []
  end

  def all
    data
  end

  def create(name, todos = [], &created)
    validate_create(name) do |name_validated|
      data << { name: name_validated, todos: todos || [] }
      created.call(name_validated) if block_given?
    end
  end

  private

  attr_reader :session

  def data
    session[:lists]
  end

  def list_names
    data.map { |list| list[:name] }
  end

  def validate_create(name)
    name = name.strip
    raise StandardError, "Please enter a name that's between 1 and 100 characters." unless name.length.between?(1, 100)
    raise StandardError, 'That list name exists. Please enter a unique list name.' if list_names.include?(name)

    yield name
  end
end
