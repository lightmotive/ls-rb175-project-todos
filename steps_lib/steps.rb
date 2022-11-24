# frozen_string_literal: true

# TODO: Refactor and publish this as a Gem.

require_relative 'sequence'
require_relative 'custom'
require_relative 'common/sanitize_web_user_input'
require_relative 'common/strip'
require_relative 'common/ensure_length_between'
require_relative 'common/ensure_not_in_collection'

module Steps
  # Convenience method to process an object with a single step using
  # Steps::Sequence to simplify using Steps::Sequence everywhere, which
  # simplifies `catch` usage.
  # To use, invoke with an object and a block { |object, step| } that returns
  # a processed object OR invokes `step#throw_failure("failure message")`.
  def self.one_step_process(object, &step_logic)
    custom_step = Custom.new do |obj, step|
      step_logic.call(obj, step)
    end
    one_step_sequence = Sequence.new([custom_step])
    one_step_sequence.process(object)
  end
end
