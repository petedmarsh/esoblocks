require 'io/console'

module Esoblocks
  module Beatnik

    DEFAULT_CHARACTER_SCORES = {
      'a' => 1,
      'b' => 3,
      'c' => 3,
      'd' => 2,
      'e' => 1,
      'f' => 4,
      'g' => 2,
      'h' => 4,
      'i' => 1,
      'j' => 8,
      'k' => 5,
      'l' => 1,
      'm' => 3,
      'n' => 1,
      'o' => 1,
      'p' => 3,
      'q' => 10,
      'r' => 1,
      's' => 1,
      't' => 1,
      'u' => 1,
      'v' => 4,
      'w' => 4,
      'x' => 8,
      'y' => 4,
      'z' => 10
    }

    DEFAULT_ACTION_SCORES = {
      5 => :push,
      6 => :pop,
      7 => :add,
      8 => :input,
      9 => :output,
      10 => :subtract,
      11 => :swap,
      12 => :dup,
      13 => :fz,
      14 => :fnz,
      15 => :bz,
      16 => :bnz,
      17 => :quit
    }

    class Interpreter
      def initialize(options= {})
        options = default_options.merge(options)
        @character_scores = options[:character_scores]
        @action_scores = options[:action_scores]
      end

      def default_options
        {
          character_scores: Esoblocks::Beatnik::DEFAULT_CHARACTER_SCORES,
          action_scores: Esoblocks::Beatnik::DEFAULT_ACTION_SCORES
        }
      end

      def score(word)
        word.downcase.each_char.inject(0) { |sum, c| sum + (@character_scores[c] || 0) }
      end

      def run(program)
        words = program.split(/\W/).reject { |word| word == ''}
        @words = words
        @current_word_index = -1
        while(execute != false)
        end
      end

      protected

      def stack
        @stack ||= Esoblocks::Stack.new 
      end

      private

      def push
        stack.push(advance)
      end

      def pop
        stack.pop
      end

      def add
        stack.push(stack.pop + stack.pop)
      end

      def input
        stack.push(STDIN.getch.ord)
      end

      def output
        print stack.pop.chr
        $stdout.flush
      end

      def subtract
        stack.push(- stack.pop + stack.pop)
      end

      def swap
        a = stack.pop
        b = stack.pop
        stack.push(a)
        stack.push(b)
      end

      def dup
        stack.push(stack.peek)
      end

      def fz
        n = advance
        advance(n) if stack.pop == 0
      end

      def fnz
        n = advance
        advance(n) if stack.pop != 0
      end

      def bz
        n = advance
        advance(-n - 1) if stack.pop == 0
      end

      def bnz
        n = advance
        advance(-n - 1) if stack.pop != 0
      end

      def quit
        false
      end

      def execute
        if @current_word_index == @words.length - 1
          return false
        end
        word_score = advance
        operation = @action_scores[word_score]
        if operation
          return self.send(operation)
        end
      end

      def current_word
        @words[@current_word_index]
      end

      def advance(n = 1)
        @current_word_index += n
        if @current_word_index >= @words.length
          raise Esoblocks::ProgramCounterOutOfBoundsError
        end
        score(@words[@current_word_index])
      end
    end
  end
end