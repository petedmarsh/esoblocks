require 'spec_helper'

describe Esoblocks do

  let(:dummy_class) { Class.new { include Esoblocks } }

  describe '#esoblock' do
    let!(:interpreter) { Esoblocks::Beatnik::Interpreter.new }
    let!(:executor) { Esoblocks::Executor.new(interpreter) }
    let(:block) { Proc.new { a b c} }

    it 'interprets and executes barewords in the givne block as a Beatnik program' do
      Esoblocks::Beatnik::Interpreter.should_receive(:new).and_return(interpreter)
      Esoblocks::Executor.should_receive(:new).with(interpreter).and_return(executor)
      interpreter.should_receive(:run).with('a b c')
      dummy_class.new.esoblock(&block)
    end
  end
end