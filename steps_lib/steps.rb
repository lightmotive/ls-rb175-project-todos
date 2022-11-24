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

  # Helper method for intuitive Steps handling: execute action,
  # then handle success or failure.
  # - `action: proc {  }`: An action that:
  #   - On success: return an object.
  #   - On failure: `throw(:failure, Steps::Messages)`.
  #   - `Steps::Sequence#process` meets those requirements.
  # - `on_success: proc { |action_proc_return_object| ... }`: invoked when
  #   `action.call` does not result in `throw(:failure)`.
  # - `on_failure: proc { |Steps::Messages| ... }`: invoked when `action.call`
  #   results in `throw(:failure)`.
  def self.process(action:, on_success:, on_failure:)
    failure_messages = catch(:failure) do
      return on_success.call(action.call)
    end

    on_failure.call(failure_messages)
  end
end
