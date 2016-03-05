class Token
  attr_reader :type, :value
  
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

  private
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

  public
  def get_next_token
    while @current_char
      case @current_char
      when /\s/
        skip_whitespace
        next
      when /[[:digit:]]/
        return Token.new(:integer, integer)
      when '+'
        advance
        return Token.new(:plus, '+')
      when '-'
        advance
        return Token.new(:minus, '-')
      when '*'
        advance
        return Token.new(:mul, '*')
      when '/'
        advance
        return Token.new(:div, '/')
      when '('
        advance
        return Token.new(:lparen, '(')
      when ')'
        advance
        return Token.new(:rparen, ')')
      else
        error
      end
    end
    Token.new(:eof, nil)
  end
end
