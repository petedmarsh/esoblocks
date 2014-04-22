module Esoblocks
  class Executor
    def initialize(interpreter)
      @program = ''
      @interpreter = interpreter
    end

    def execute(&block)
      instance_eval(&block)
      @interpreter.run(@program)
    end

    private

    def method_missing(method_name, *args, &block)
      @program.prepend(' ') unless @program == ''
      @program.prepend(method_name.to_s)
    end
  end
end
