module Esoblocks
  class StackError < StandardError; end
  class StackUnderflowError < StandardError; end
  class StackOverflowError < StandardError; end
  class ProgramCounterOutOfBoundsError < StandardError; end
end