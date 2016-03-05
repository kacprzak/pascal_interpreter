#!/usr/bin/ruby
require_relative 'lexer'

class Interpreter
  def initialize(lexer)
    @lexer = lexer
    @current_token = @lexer.get_next_token
  end

  def error
    raise 'Invalid syntax'
  end
  
  def eat(token_type)
    if @current_token.type == token_type
      @current_token = @lexer.get_next_token
    else
      error
    end
  end

  # return an integer token value
  def factor
    token = @current_token
    eat :integer
    token.value
  end
  
  # expr -> factor * factor
  # expr -> factor / factor
  def term
    result = factor
    while [:mul, :div].include? @current_token.type
      token = @current_token
      if token.type == :mul
        eat :mul
        result = result * factor
      elsif token.type == :div
        eat :div
        result = result / factor
      end
    end
    result
  end

  # expr -> term + term
  # expr -> term - term
  def expr
    result = term
    while [:plus, :minus].include? @current_token.type
      token = @current_token
      if token.type == :plus
        eat :plus
        result = result + term
      elsif token.type == :minus
        eat :minus
        result = result - term
      end
    end
    result
  end
end


def main
  loop do
    print 'calc> '
    $stdout.flush
    text = gets.chomp
    next if text.empty?
    lexer = Lexer.new(text)
    interpreter = Interpreter.new(lexer)
    puts interpreter.expr
  end
end

if __FILE__ == $0
  main
end
