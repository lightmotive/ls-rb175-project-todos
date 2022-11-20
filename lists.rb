# frozen_string_literal: true

class Lists
  def initialize(session = { lists: [] })
    @session = session
    session[:lists] ||= []
  end

  def all
    data
  end

  def create(name, todos = [])
    name = name.strip
    raise StandardError, "Please enter a name that's between 1 and 100 characters." unless name.length.between?(1, 100)

    data << { name: name, todos: todos || [] }
  end

  private

  attr_reader :session

  def data
    session[:lists]
  end
end
