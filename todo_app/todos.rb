# frozen_string_literal: true

require 'random/formatter'
require_relative 'mocks'
require './sequence_lib/main'
require_relative 'lists'

module TodoApp
  # Session-based Lists/Todos Data Access Object.
  class Todos
    def initialize(session, list_id)
      @session = session || TodoApp::Mocks::SESSION
      @list_id = list_id
    end

    def all
      data
    end

    def create(name)
      todo = {
        id: Random.uuid,
        name: validate_name(name),
        done: false
      }
      data << todo
      todo
    end

    def [](id)
      # Acknowledgement: this isn't a performant data store; a production app
      # would use a database for efficient lookup by unique ID.
      # For practice purposes, this is sufficient.
      Sequence.one_step_process(
        data.select { |todo| todo[:id] == id }.first
      ) do |todo, step|
        todo.nil? ? step.throw_failure("That todo doesn't exist.") : todo
      end
    end

    def edit(id, name)
      todo = self[id]
      todo[:name] = validate_name(name)
      todo
    end

    def mark(id, done:)
      unless done.is_a?(TrueClass) || done.is_a?(FalseClass)
        raise ArgumentError, 'Second argument must be a boolean value.'
      end

      self[id][:done] = done
    end

    def delete(id)
      data.delete_if { |todo| todo[:id] == id } if self[id]
    end

    private

    def data
      Lists.new(@session)[@list_id][:todos]
    end

    def validate_name(name)
      Sequence::Sequence.new(
        [Sequence::Common::SanitizeWebUserInput,
         Sequence::Common::Strip,
         Sequence::Common::EnsureLengthBetween.new(1, 100, value_name: 'Name')]
      ).process(name)
    end
  end
end
