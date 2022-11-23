# frozen_string_literal: true

require_relative 'validators/validation_error'
require_relative 'validators/custom'
require_relative 'validators/length'
require_relative 'validators/not_in_collection'
require_relative 'validators/sanitize_web_user_input'
require_relative 'validators/strip'

module TodoApp
  # Contains a list of error messages.
  class ValidationErrors < StandardError
    def initialize(messages)
      super(messages.join("\n"))

      @messages = messages
    end

    def messages_as_html(wrapper_div_class: nil)
      "<div#{wrapper_div_class ? "class=\"#{wrapper_div_class}\"" : ''}>\n" \
      "<div>#{@messages.join("</div>\n<div>")}</div>\n" \
      '</div>'
    end
  end

  # Validate a value using a list of `Validator`-derived objects.
  # `#do(value, [*validator])` - each `validator` must:
  # - Have a `validate` method that:
  #   - Returns a validated value.
  #   - OR raises `ValidationError`.
  # - AND be one of the following:
  #   - A class that can be initialized with no arguments (`element.is_a?(Class)`).
  #   - A class instance.
  class ValidateAll
    # Run all validators.
    # - If no exceptions, this returns the validated value. `validators` can
    #   sequentially mutate `value`.
    # - Otherwise, this will raise a ValidationErrors exception that contains
    #   all error messages.
    def self.do(value, validators)
      raise StandardError, 'Provide at least 1 validator.' if validators.empty?

      errors = []
      validators.each do |validator|
        validator = validator.new if validator.is_a?(Class)
        value = validator.validate(value)
      rescue Validators::ValidationError => e
        errors << e
        break if validator.respond_to?(:skip_subsequent_validations_after_exception?) \
                 && validator.skip_subsequent_validations_after_exception?
      end
      raise ValidationErrors, errors.map(&:message) unless errors.empty?

      value
    end
  end
end
