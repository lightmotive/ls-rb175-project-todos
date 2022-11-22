# frozen_string_literal: true

require './validation_error'
require './sanitize_user_input'

# Session-based Lists Data Access Object.
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
    validate_name_new(name) do |name_validated|
      data << { name: name_validated, todos: todos || [] }
      validated.call(name_validated) if block_given?
    end
  end

  def [](idx)
    data[idx]
  end

  def edit(idx, name, &validated)
    list = data[idx]
    raise ValidationError, "That list doesn't exist." if list.nil?

    validate_name_edit(idx, name) do |name_validated|
      list[:name] = name_validated
      validated.call(name_validated)
    end
  end

  def delete(idx)
    deleted = data.delete_at(idx)
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

  def validate_name_edit(idx, name, &validated)
    validate_name_all(name) do |name_validated|
      list_names_except_current = list_names
      list_names_except_current.delete_at(idx)
      if list_names_except_current.include?(name_validated)
        raise ValidationError, 'That list name exists. Please enter a unique name.'
      end

      validated.call(name_validated)
    end
  end
end
