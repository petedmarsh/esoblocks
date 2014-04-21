require 'spec_helper'

describe Esoblocks::Beatnik::Interpreter do
  let(:character_scores) { Esoblocks::Beatnik::DEFAULT_CHARACTER_SCORES }
  let(:action_scores) { Esoblocks::Beatnik::DEFAULT_ACTION_SCORES }
  let(:stack) { Esoblocks::Stack.new }
  let(:interpreter) do
    interpreter = Esoblocks::Beatnik::Interpreter.new(
      character_scores: character_scores,
      action_scores: action_scores
    )
  end

  before do
    interpreter.stub(:stack).and_return(stack)
  end

  describe '#score' do
    let(:character_scores) { { 'a' => 2, 'b' => 3, 'c' => 5 } }

    subject { interpreter.score(word) }

    context 'when word contains' do
      context 'only characters in the distribution' do
        let(:word) { 'abc' }

        it { should eq 10 }
      end

      context 'uppercase versions of characters in the distribution' do
        let(:word) { 'ABC' }

        it { should eq 10 }
      end

      context 'characters which do not appear in the distribution' do
        let(:word) { 'axbycz' }

        it 'ignores the unknown characters and they do not add to the score' do
          should eq 10
        end
      end
    end
  end

  describe '#run' do
    let(:character_scores) { { 'p' => 5, 'x' => 2, 'q' => 17 } }

    context 'when the program' do
      context 'contains non-word characters' do
        let(:program) { 'p/!!!x' }
        it 'splits the string on non-word boundaries then executes the program' do
          interpreter.run(program)
          stack.peek.should eq character_scores['x']
        end
      end

      context 'contains a quit instruction that gets executed' do
        let(:program) { 'p x q p x' }

        it 'executes the program until the quit instruction then terminates' do
          interpreter.run(program)
          stack.peek.should eq character_scores['x']
          stack.elements.length.should eq 1
        end
      end
    end
  end

# The following are tests for private methods. Testing these methods directly is much
# clearer than trying to exercise their behaviour via running Beatnik code through +run+!

  describe '#push' do
    let(:value) { 123 }

    before do
      interpreter.should_receive(:advance).and_return(value)
    end

    it 'pushes the score of the next word to the stack' do
      interpreter.send(:push)
      stack.peek.should eq value
    end
  end

  describe '#pop' do
    let (:value) { 123 }

    context 'when the stack' do
      context 'is not empty' do
        before do
          stack.push(value)
        end

        it 'pops the stack' do
          interpreter.send(:pop)
          stack.elements.should eq []
        end
      end

      context 'is empty' do
        it do 
          expect { interpreter.send(:pop) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#add' do
    context 'when the stack' do
      context 'has two or more elements' do
        let(:a) { 123 }
        let(:b) { 456 }
        
        before do
          stack.push(a)
          stack.push(b)
        end

        it 'pops two elements from the stack, adds them, then pushes the result' do
          interpreter.send(:add)
          stack.peek.should eq a + b
        end
      end

      context 'has fewer than two elements' do
        it do 
          expect { interpreter.send(:add) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#input' do
    let(:ch) { 'x' }

    before do
      STDIN.should_receive(:getch).and_return(ch)
    end

    it 'gets one character from STDIN and pushes its value to the stack' do
      interpreter.send(:input)
      stack.peek.should eq ch.ord
    end
  end

  describe '#output' do
    context 'when the stack' do
      context 'is not empty' do
        let(:value) { 123 }

        before do
          stack.push(value)
        end

        it 'pops the stack and prints the value as an ASCII character' do
          interpreter.should_receive(:print).with(value.chr)
          interpreter.send(:output)
        end
      end

      context 'is empty' do
        it do 
          expect do
            interpreter.send(:output)
          end.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#subtract' do
    context 'when the stack' do
      context 'has two or more elements' do
        let(:a) { 123 }
        let(:b) { 456 }
        
        before do
          stack.push(a)
          stack.push(b)
        end

        it 'pops two elements from the stack, subtracts the first (topmost) from the second, then pushes the result' do
          interpreter.send(:subtract)
          stack.peek.should eq a - b
        end
      end

      context 'has fewer than two elements' do
        it do 
          expect { interpreter.send(:subtract) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#swap' do
    context 'when the stack' do
      context 'has two or more elements' do
        let(:a) { 123 }
        let(:b) { 456 }
        
        before do
          stack.push(a)
          stack.push(b)
        end

        it 'pops two elements from the stack, then pushes them back in reverse order' do
          interpreter.send(:swap)
          stack.elements.should eq [b, a]
        end
      end

      context 'has fewer than two elements' do
        it do 
          expect { interpreter.send(:swap) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#dup' do
    context 'when the stack' do
      context 'is not empty' do
        let(:value) { 123 }

        before do
          stack.push(value)
        end

        it 'pops a value from the stack then pushes it twice' do
          interpreter.send(:dup)
          stack.elements.should eq [value, value]
        end
      end

      context 'is empty' do
        it do 
          expect { interpreter.send(:dup) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#fz' do
    context 'when the stack' do
      context 'is not empty' do
        before do
          stack.push(value)
        end

        context 'and the value on top of the stack is' do
          context 'zero' do
            let(:value) { 0 }
            let(:next_word_value) { 123 }
            
            it 'finds the score of the next word then advances by that number' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_receive(:advance).with(next_word_value)
              interpreter.send(:fz)
            end
          end

          context 'not zero' do
            let(:value) { 1 }
            let(:next_word_value) { 123 }
            
            it 'does not advance' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_not_receive(:advance)
              interpreter.send(:fz)
            end
          end

          context 'but there are no more words left' do
            let(:value) { 123 }

            before do
              interpreter.instance_variable_set(:@words, [])
              interpreter.instance_variable_set(:@current_word_index, -1)
            end

            it do
              expect { interpreter.send(:fz) }.to raise_error Esoblocks::ProgramCounterOutOfBoundsError
            end
          end

        end
      end

      context 'is empty' do
        it do 
          interpreter.stub(:advance)
          expect { interpreter.send(:fz) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#fnz' do
    context 'when the stack' do
      context 'is not empty' do
        before do
          stack.push(value)
        end

        context 'and the value on top of the stack is' do
          context 'zero' do
            let(:value) { 0 }
            let(:next_word_value) { 123 }
            
            it 'does not advance' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_not_receive(:advance)
              interpreter.send(:fnz)
            end
          end

          context 'not zero' do
            let(:value) { 1 }
            let(:next_word_value) { 123 }
            
            it 'finds the score of the next word then advances by that number' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_receive(:advance).with(next_word_value)
              interpreter.send(:fnz)
            end
          end

          context 'but there are no more words left' do
            let(:value) { 123 }

            before do
              interpreter.instance_variable_set(:@words, [])
              interpreter.instance_variable_set(:@current_word_index, -1)
            end

            it do
              expect { interpreter.send(:fnz) }.to raise_error Esoblocks::ProgramCounterOutOfBoundsError
            end
          end

        end
      end

      context 'is empty' do
        it do 
          interpreter.stub(:advance)
          expect { interpreter.send(:fnz) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#bz' do
    context 'when the stack' do
      context 'is not empty' do
        before do
          stack.push(value)
        end

        context 'and the value on top of the stack is' do
          context 'zero' do
            let(:value) { 0 }
            let(:next_word_value) { 123 }
            
            it 'finds the score of the next word then retreats by that number' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_receive(:advance).with(-next_word_value - 1)
              interpreter.send(:bz)
            end
          end

          context 'not zero' do
            let(:value) { 1 }
            let(:next_word_value) { 123 }
            
            it 'does not retreat' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_not_receive(:advance)
              interpreter.send(:bz)
            end
          end

          context 'but there are no more words left' do
            let(:value) { 123 }

            before do
              interpreter.instance_variable_set(:@words, [])
              interpreter.instance_variable_set(:@current_word_index, -1)
            end

            it do
              expect { interpreter.send(:bz) }.to raise_error Esoblocks::ProgramCounterOutOfBoundsError
            end
          end

        end
      end

      context 'is empty' do
        it do 
          interpreter.stub(:advance)
          expect { interpreter.send(:bz) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#bnz' do
    context 'when the stack' do
      context 'is not empty' do
        before do
          stack.push(value)
        end

        context 'and the value on top of the stack is' do
          context 'zero' do
            let(:value) { 0 }
            let(:next_word_value) { 123 }
            
            it 'does not retreat' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_not_receive(:advance)
              interpreter.send(:bnz)
            end
          end

          context 'not zero' do
            let(:value) { 1 }
            let(:next_word_value) { 123 }
            
            it 'finds the score of the next word then retreats by that number' do
              interpreter.should_receive(:advance).and_return(next_word_value)
              interpreter.should_receive(:advance).with(-next_word_value - 1)
              interpreter.send(:bnz)
            end
          end

          context 'but there are no more words left' do
            let(:value) { 123 }

            before do
              interpreter.instance_variable_set(:@words, [])
              interpreter.instance_variable_set(:@current_word_index, -1)
            end

            it do
              expect { interpreter.send(:bnz) }.to raise_error Esoblocks::ProgramCounterOutOfBoundsError
            end
          end

        end
      end

      context 'is empty' do
        it do 
          interpreter.stub(:advance)
          expect { interpreter.send(:bnz) }.to raise_error Esoblocks::StackUnderflowError
        end
      end
    end
  end

  describe '#quit' do
    subject { interpreter.send(:quit) }

    it { should eq false }
  end
end