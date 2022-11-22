# frozen_string_literal: true

require './todo_app/validation_error'
require './todo_app/sanitize_user_input'
require './todo_app/mocks'

class Todos
  include SanitizeUserInput

  def initialize(session, list_id)
    @session = session || TodoApp::Mocks::SESSION
    @list_id = list_id
  end

  def all
    data
  end

  def create(name, &validated)
    validate_name(name) do |name_validated|
      data << { name: name_validated, done: false }
      validated.call(name_validated) if block_given?
    end
  end

  def [](id)
    data[id]
  end

  def edit(id, name, &validated)
    todo = data[id]
    raise ValidationError, "That todo doesn't exist." if todo.nil?

    validate_name(name) do |name_validated|
      todo[:name] = name_validated
      validated.call(name_validated) if block_given?
    end
  end

  def mark(id, is_done)
    unless is_done.is_a?(TrueClass) || is_done.is_a?(FalseClass)
      raise ArgumentError, 'Second argument must be true or false.'
    end

    self[id][:done] = is_done
  end

  def delete(id)
    data.delete_at(id)
  end

  private

  attr_reader :session, :list_id

  def data
    session[:lists][list_id][:todos]
  end

  def validate_name(name)
    name_validated = sanitize_fragment(name).strip

    unless name_validated.length.between?(1, 100)
      raise ValidationError, "Please enter a name that's between 1 and 100 characters."
    end

    yield name_validated
  end
end
