require "esoblocks/version"
require "esoblocks/stack"
require "esoblocks/exceptions"
require "esoblocks/beatnik/interpreter"
require "esoblocks/executor"

module Esoblocks
  def esoblock(&block)
    interpreter = Esoblocks::Beatnik::Interpreter.new
    executor = Esoblocks::Executor.new(interpreter)
    executor.execute(&block)
  end
end

class Object
  include Esoblocks
end