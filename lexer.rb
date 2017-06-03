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
  RESERVED_KEYWORDS = {'PROGRAM' => Token.new(:program, 'PROGRAM'),
                       'VAR' => Token.new(:var, 'VAR'),
                       'DIV' => Token.new(:integer_div, 'DIV'),
                       'INTEGER' => Token.new(:integer, 'INTEGER'),
                       'REAL' => Token.new(:real, 'REAL'),
                       'BEGIN' => Token.new(:begin, 'BEGIN'),
                       'END' => Token.new(:end, 'END') }

  def initialize(text)
    @text = text
    @pos = 0
    @current_char = @text[@pos]
  end

  private
  def error
    raise  "Wrong char: #{@current_char}"
  end

  def peek
    peek_pos = @pos + 1
    if peek_pos > @text.length - 1
      nil
    else
      @text[peek_pos]
    end
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

  def skip_comment
    advance while @current_char != '}'
    advance # the closing curly bracket
  end

  # Return a (multidigit) integer or float consumed from the input.
  def number
    result = ''
    while @current_char and @current_char =~ /[[:digit:]]/
      result << @current_char
      advance
    end

    if @current_char == '.'
      result << @current_char
      advance
      while @current_char and @current_char =~ /[[:digit:]]/
        result << @current_char
        advance
      end
      Token.new(:real_const, result.to_f)
    else
      Token.new(:integer_const, result.to_i)
    end
  end

  def id
    result = ''
    while @current_char and @current_char =~ /_|[[:alnum:]]/
      result << @current_char
      advance
    end
    RESERVED_KEYWORDS.fetch(result.upcase, Token.new(:id, result))
  end

  public
  def get_next_token
    while @current_char
      case @current_char
      when /\s/
        skip_whitespace
        next
      when '{'
        skip_comment
        next
      when /_|[[:alpha:]]/
        return id
      when /[[:digit:]]/
        return number
      when ':'
        if peek == '='
          advance
          advance
          return Token.new(:assign, ':=')
        else
          advance
          return Token.new(:colon, ':')
        end
      when ';'
        advance
        return Token.new(:semi, ';')
      when '.'
        advance
        return Token.new(:dot, '.')
      when ','
        advance
        return Token.new(:comma, ',')
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
        return Token.new(:float_div, '/')
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
