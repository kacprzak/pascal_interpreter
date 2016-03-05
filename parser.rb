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


class UnaryOp < AST
  attr_reader :token, :child
  alias_method :op, :token

  def initialize(token, child)
    @token = token
    @child = child
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

  # factor : (PLUS | MINUS) factor | INTEGER | LPAREN expr RPAREN
  def factor
    token = @current_token
    if token.type == :plus
      eat :plus
      UnaryOp.new(token, factor)
    elsif token.type == :minus
      eat :minus
      UnaryOp.new(token, factor)
    elsif token.type == :integer
      eat :integer
      Num.new(token)
    elsif token.type == :lparen
      eat :lparen
      node = expr
      eat :rparen
      node
    end
  end
  
  # term: factor ((MUL | DIV) factor)*
  def term
    node = factor
    while [:mul, :div].include? @current_token.type
      token = @current_token
      if token.type == :mul
        eat :mul
      elsif token.type == :div
        eat :div
      end
      node = BinOp.new(node, token, factor)
    end
    node
  end

  # expr: term ((PLUS | MINUS) term)*
  def expr
    node = term
    while [:plus, :minus].include? @current_token.type
      token = @current_token
      if token.type == :plus
        eat :plus
      elsif token.type == :minus
        eat :minus
      end
      node = BinOp.new(node, token, term)
    end
    node
  end
end
