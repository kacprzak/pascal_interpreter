#!/usr/bin/ruby
require_relative 'lexer'

class AST
end


class BinOp < AST
  attr_reader :left, :token, :right
  alias_method :op, :token

  def initialize(left, token, right)
    @left = left
    @token = token
    @right = right
  end
end


class Num < AST
  attr_reader :token
  
  def initialize(token)
    @token = token
  end

  def value
    @token.value
  end
end


class Parser
  def initialize(lexer)
    @lexer = lexer
    @current_token = @lexer.get_next_token
  end

  def parse
    expr
  end
  
  private
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

  # factor : INTEGER | LPAREN expr RPAREN
  def factor
    token = @current_token
    if token.type == :integer
      eat :integer
      token.value
    elsif token.type == :lparen
      eat(:lparen)
      result = expr
      eat(:rparen)
      result
    end
  end
  
  # term: factor ((MUL | DIV) factor)*
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

  # expr: term ((PLUS | MINUS) term)*
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
    interpreter = Parser.new(lexer)
    puts interpreter.parse
  end
end

if __FILE__ == $0
  main
end
