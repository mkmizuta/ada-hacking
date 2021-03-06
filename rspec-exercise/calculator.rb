require 'forwardable'
class Calculator
  def add(*numbers)
    numbers.flatten.inject(0, &:+)
  end

  def subtract(*numbers)
    numbers.inject(numbers.shift, &:-)
  end

  def multiply(*numbers)
    numbers.inject(1, &:*)
  end

  def divide(*numbers)
    numbers.inject(numbers.shift, &:/)
  end

  def evaluate(expression)
    Evaluator.new(expression).call
  end

  class Evaluator
    attr_reader :expression
    def initialize(expression)
      @expression  = expression
      @accumulator = nil
      @operator    = nil
    end

    attr_accessor :accumulator, :operator
    private :accumulator, :operator

    def call
      until tokens.empty?
        case tokens.first
        when /\d+/        ; process_integer!
        when /[\+\-\*\/]/ ; process_operator!
        else raise "I don't understand #{expression.inspect}"
        end
      end
      accumulator
    end

    private

    def process_integer!
      value = tokens.consume.to_i
      case
      when accumulator.nil? # should only be the first time through
        self.accumulator = value
      when operator.nil?
        raise "I don't understand #{expression.inspect}"
      else
        self.accumulator = accumulator.send(operator, value)
      end
    end

    def process_operator!
      self.operator = tokens.consume.to_sym
    end

    def tokens
      @tokens ||= Tokenizer.new(expression)
    end
  end

  class Tokenizer
    def initialize(string)
      @string = string
    end

    extend Forwardable
    def_delegators :tokens, :empty?, :first

    def consume
      tokens.shift
    end

    private

    def tokens
      @tokens ||=
        begin
          @string.gsub(/\s+/, '').split(/\b/)
        end
    end
  end
end
