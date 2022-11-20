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
    data << { name: name, todos: todos || [] }
  end

  private

  attr_reader :session

  def data
    session[:lists]
  end
end
