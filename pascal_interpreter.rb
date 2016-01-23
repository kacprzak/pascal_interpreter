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
  end

  def error(msg)
    raise "Error parsing input(#{@pos}). #{msg}"
  end
  
  def get_next_token
    return Token.new(:eof, nil) if @pos >= @text.length

    current_char = @text[@pos]

    if current_char =~ /[[:digit:]]/
      @pos += 1
      return Token.new(:integer, current_char.to_i)
    end

    if current_char == '+'
      @pos += 1
      return Token.new(:plus, current_char)
    end

    error "Wrong char: #{current_char}"
  end

  def eat(token_type)
    if @current_token.type == token_type
      @current_token = get_next_token
    else
      error "Wrong token: #{token_type}"
    end
  end

  # expr -> integer + integer
  def expr
    @current_token = get_next_token

    left = @current_token
    eat(:integer)

    op = @current_token
    eat(:plus)

    right = @current_token
    eat(:integer)

    left.value + right.value
  end
end

def main
  loop do
    print 'calc> '
    $stdout.flush
    text = gets.chomp
    break if text.empty?
    interpreter = Interpreter.new(text)
    puts interpreter.expr
  end
end

if __FILE__ == $0
  main
end
