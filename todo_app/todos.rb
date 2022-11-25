# frozen_string_literal: true

require_relative 'mocks'
require './steps_lib/steps'

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
      todo = { name: validate_name(name), done: false }
      data << todo
      todo
    end

    def [](id)
      Steps.one_step_process(data[id]) do |todo, step|
        todo.nil? ? step.throw_failure("That todo doesn't exist.") : todo
      end
    end

    def edit(id, name)
      todo = self[id]
      todo[:name] = validate_name(name)
      todo
    end

    def mark(id, is_done)
      # unless is_done.is_a?(TrueClass) || is_done.is_a?(FalseClass)
      #   raise ArgumentError, 'Second argument must be true or false.'
      # end

      self[id][:done] = is_done
    end

    def mark_toggle(id)
      mark(id, !self[id][:done])
    end

    def delete(id)
      data.delete_at(id) if self[id]
    end

    private

    attr_reader :session, :list_id

    def data
      session[:lists][list_id][:todos]
    end

    def validate_name(name)
      Steps::Sequence.new(
        [Steps::Common::SanitizeWebUserInput,
         Steps::Common::Strip,
         Steps::Common::EnsureLengthBetween.new(1, 100, value_name: 'Name')]
      ).process(name)
    end
  end
end
