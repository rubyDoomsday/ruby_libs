# frozen_string_literal: true

class ApplicationService
  private_class_method :new

  # @param args [Hash] A set of named arguments
  # @param block [Proc] A block to inject behavior
  # @return [ApplicationService]
  # @yield [ApplicationService]
  def self.call(*args, &block)
    new(*args, &block).tap do |service|
      service.send(:call)

      if block_given?
        yield service
      else
        service
      end
    end
  end

  attr_reader :result

  def success
    yield result if success?
  end

  def failure
    yield errors if failure?
  end

  def success?
    errors.empty?
  end

  def failure?
    !success?
  end

  def errors
    @errors ||= []
  end

  private

  # @note This method should not be used to return any value,
  # use #result! instead
  # @return nil
  def call
    raise NotImplementedError
  end

  def result!(result)
    @result = result
  end

  def errors!(errors)
    @errors = errors
  end
end
