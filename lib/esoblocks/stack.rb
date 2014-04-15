module Esoblocks
  class Stack
    attr_reader :elements

    def initialize
      @elements = []
    end

    def peek
      raise Esoblocks::StackUnderflowError if @elements.empty?
      @elements.last
    end

    def pop
      raise Esoblocks::StackUnderflowError if @elements.empty?
      @elements.pop
    end

    def push(element)
      @elements.push(element)
    end
  end
end