# frozen_string_literal: true

require './sanitize_user_input'

class Lists
  include SanitizeUserInput

  def initialize(session = { lists: [] })
    @session = session
    session[:lists] ||= []
  end

  def all
    data
  end

  def create(name, todos = [], &validated)
    validate_create(name) do |name_validated|
      data << { name: name_validated, todos: todos || [] }
      validated.call(name_validated) if block_given?
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
    name_validated = sanitize_fragment(name).strip
    unless name_validated.length.between?(
      1, 100
    )
      raise StandardError,
            "Please enter a name that's between 1 and 100 characters."
    end

    if list_names.include?(name_validated)
      raise StandardError,
            'That list name exists. Please enter a unique list name.'
    end

    yield name_validated
  end
end
