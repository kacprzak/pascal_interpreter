#!/usr/bin/ruby
class Token
  attr_accessor :type, :value
  
  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "Token(#{@type}, #{@value})"
  end
end


class Lexer
  def initialize(text)
    @text = text
    @pos = 0
    @current_char = @text[@pos]
  end

  def error
    raise  "Wrong char: #{@current_char}"
  end

  def advance
    @pos += 1
    if @pos > @text.length - 1
      @current_char = nil
    else
      @current_char = @text[@pos]
    end
  end

  def skip_whitespace
    advance while @current_char and @current_char =~ /\s/
  end

  # Consume integer
  def integer
    result = ''
    while @current_char and @current_char =~ /[[:digit:]]/
      result << @current_char
      advance
    end
    result.to_i
  end
  
  def get_next_token
    while @current_char
      if @current_char =~/\s/
        skip_whitespace
        next
      end

      if @current_char =~ /[[:digit:]]/
        return Token.new(:integer, integer)
      end

      if @current_char == '+'
        advance
        return Token.new(:plus, '+')
      end

      if @current_char == '-'
        advance
        return Token.new(:minus, '-')
      end

      error
    end
    Token.new(:eof, nil)
  end
end


class Interpreter
  def initialize(lexer)
    @lexer = lexer
    @current_token = nil
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
  def term
    token = @current_token
    eat :integer
    token.value
  end
  
  # expr -> integer + integer
  # expr -> integer - integer
  def expr
    @current_token = @lexer.get_next_token

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
