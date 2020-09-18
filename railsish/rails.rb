# frozen_string_literal: true

# Provided to ensure Railsy behavior for libraries
# extricated from an existing Rails ENV (which
# includes additional methods on standard classes)
require_relative "patch/array"
require_relative "patch/hash"
require_relative "patch/string"
require_relative "patch/time"

class Rails
  def self.root
    Root.new(ROOT)
  end

  def self.logger
    Logger.new(:noop)
  end

  Root = Struct.new(:dir) do
    def path
      "#{File.expand_path(dir)}/#{APP_NAME}/"
    end

    def join(args)
      ([path] + Array(args)).join
    end
  end

  Logger = Struct.new(:ouput) do
    def warn(*args); end

    def error(*args); end
  end
end
