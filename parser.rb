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


class Compound < AST
  attr_accessor :children
  
  def initialize
    @children = []
  end
end


class Assign < AST
  attr_reader :left, :token, :right
  alias_method :op, :token

  def initialize(left, token, right)
    @left = left
    @token = token
    @right = right
  end
end


class Var < AST
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def value
    @token.value
  end
end


class NoOp < AST
end


class Parser
  def initialize(lexer)
    @lexer = lexer
    @current_token = @lexer.get_next_token
  end

  def parse
    node = program
    error if @current_token.type != :eof
    node
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

  # program: compound_statement DOT
  def program
    node = compound_statement
    eat(:dot)
    node
  end

  # compound_statement: BEGIN statement_list END
  def compound_statement
    eat(:begin)
    nodes = statement_list
    eat(:end)
    root = Compound.new
    root.children = nodes
    root
  end

  # statement_list: statement | statement SEMI statement_list
  def statement_list
    results = [statement]
    results
    while @current_token.type == :semi
      eat(:semi)
      results << statement
    end
    error if @current_token.type == :id
    results
  end

  # statement: compound_statement | assignment_statement | empty
  def statement
    if @current_token.type == :begin
      compound_statement
    elsif @current_token.type == :id
      assignment_statement
    else
      empty
    end
  end

  # assignment_statement: variable ASSIGN expr
  def assignment_statement
    left = variable
    token = @current_token
    eat(:assign)
    right = expr
    Assign.new(left, token, right)
  end

  # variable: ID
  def variable
    node = Var.new(@current_token)
    eat(:id)
    node
  end

  # empty production
  def empty
    NoOp.new
  end

  # factor : (PLUS | MINUS) factor | INTEGER | LPAREN expr RPAREN | variable
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
    else
      variable
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
