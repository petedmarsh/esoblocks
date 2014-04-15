require 'spec_helper'

describe Esoblocks::Stack do
  let(:stack) { Esoblocks::Stack.new }

  describe '#peek' do
    context 'when the stack is' do
      context 'empty' do
        it 'raises a Esoblocks::StackUnderflowError' do
          expect { stack.peek }.to raise_error Esoblocks::StackUnderflowError
        end
      end

      context 'not empty' do
        let(:element) { 1 }
        
        before :each  do
          stack.push(element)
        end

        it 'returns the top element' do
          stack.peek.should eq element
        end
      end
    end
  end

  describe '#pop' do
    context 'when the stack is' do
      context 'empty' do
        it 'raises a Esoblocks::StackUnderflowError' do
          expect { stack.pop }.to raise_error Esoblocks::StackUnderflowError
        end
      end

      context 'not empty' do
        let(:element) { 1 }
        
        before :each  do
          stack.push(element)
        end

        it 'returns the top element' do
          stack.pop.should eq element
        end

        it 'removes the element from the stack' do
          stack.pop
          stack.elements.last.should_not eq element
        end
      end
    end
  end

  describe '#push'  do
    it 'puts an element on the top of the stack' do
      stack.push(1)
      stack.push(2)
      expect(stack.elements).to eq [1, 2]
    end
  end
end