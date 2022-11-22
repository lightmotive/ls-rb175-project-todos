# frozen_string_literal: true

require './todo_app/validation_error'
require './todo_app/sanitize_user_input'
require './todo_app/mocks'

# Session-based Lists Data Access Object.
class Lists
  include SanitizeUserInput

  def initialize(session = TodoApp::Mocks::SESSION)
    @session = session
    session[:lists] ||= []
  end

  def all
    data
  end

  def create(name, todos = [], &validated)
    validate_name_new(name) do |name_validated|
      data << { name: name_validated, todos: todos || [] }
      validated.call(name_validated) if block_given?
    end
  end

  def [](id)
    data[id]
  end

  def edit(id, name, &validated)
    list = data[id]
    raise ValidationError, "That list doesn't exist." if list.nil?

    validate_name_edit(id, name) do |name_validated|
      list[:name] = name_validated
      validated.call(name_validated)
    end
  end

  def delete(id)
    deleted = data.delete_at(id)
    raise ValidationError, "That list doesn't exist." if deleted.nil?

    deleted
  end

  private

  attr_reader :session

  def data
    session[:lists]
  end

  def list_names
    data.map { |list| list[:name] }
  end

  def validate_name_all(name)
    name_validated = sanitize_fragment(name).strip

    unless name_validated.length.between?(1, 100)
      raise ValidationError, "Please enter a name that's between 1 and 100 characters."
    end

    yield name_validated
  end

  def validate_name_new(name, &validated)
    validate_name_all(name) do |name_validated|
      raise ValidationError, 'That list name exists. Please enter a unique name.' if list_names.include?(name_validated)

      validated.call(name_validated)
    end
  end

  def validate_name_edit(id, name, &validated)
    validate_name_all(name) do |name_validated|
      list_names_except_current = list_names
      list_names_except_current.delete_at(id)
      if list_names_except_current.include?(name_validated)
        raise ValidationError, 'That list name exists. Please enter a unique name.'
      end

      validated.call(name_validated)
    end
  end
end
