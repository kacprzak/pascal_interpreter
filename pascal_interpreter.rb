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

class Interpreter
  def initialize(text)
    @text = text
    @pos = 0
    @current_token = nil
    @current_char = @text[@pos]
  end

  def error(msg)
    raise "Error parsing input(#{@pos}). #{msg}"
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

      error "Wrong char: #{@current_char}"
    end
    Token.new(:eof, nil)
  end
  
  def eat(token_type)
    if @current_token.type == token_type
      @current_token = get_next_token
    else
      error "Wrong token: #{token_type}"
    end
  end

  # expr -> integer + integer
  # expr -> integer - integer
  def expr
    @current_token = get_next_token

    left = @current_token
    eat(:integer)

    op = @current_token
    if op.type == :plus
      eat(:plus)
    else
      eat(:minus)
    end
    
    right = @current_token
    eat(:integer)

    if op.type == :plus
      left.value + right.value
    else
      left.value - right.value
    end
  end
end

def main
  loop do
    print 'calc> '
    $stdout.flush
    text = gets.chomp
    next if text.empty?
    interpreter = Interpreter.new(text)
    puts interpreter.expr
  end
end

if __FILE__ == $0
  main
end
