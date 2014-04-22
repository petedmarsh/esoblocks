require 'spec_helper'

describe Esoblocks::Executor do
  let(:interpreter) { Esoblocks::Beatnik::Interpreter.new }
  let(:executor) { Esoblocks::Executor.new(interpreter) }

  describe '#method_missing' do
    it 'preppends the name of the method as a string to @program' do
      method_name_1 = :some_method
      method_name_2 = :some_other_method
      executor.send(:method_missing, method_name_1)
      executor.send(:method_missing, method_name_2)
      executor.instance_variable_get(:@program).should eq "#{method_name_2} #{method_name_1}"
    end
  end

  describe '#execute' do
    it 'calls instance_eval on the given block, then runs the intrepreter with @program' do
      interpreter.should_receive(:run).with('a b c')
      executor.execute { a b c }
    end
  end
end