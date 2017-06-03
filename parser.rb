require_relative 'lexer'

class AST
end

# Root node
class Program < AST
  attr_reader :name, :block

  def initialize(name, block)
    @name = name
    @block = block
  end
end

# Declarations and compound statements
class Block < AST
  attr_reader :declarations, :compound_statement

  def initialize(declarations, compound_statement)
    @declarations = declarations
    @compound_statement = compound_statement
  end
end

# Variable declaration
class VarDecl < AST
  attr_reader :var_node, :type_node

  def initialize(var_node, type_node)
    @var_node = var_node
    @type_node = type_node
  end
end


class Type < AST
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def value
    @token.value
  end
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

  # program: PROGRAM variable SEMI block DOT
  def program
    eat :program
    prog_name = variable.value
    eat :semi
    node = Program.new(prog_name, block)
    eat :dot
    node
  end

  # block: declarations compound_statement
  def block
    Block.new(declarations, compound_statement)
  end

  # declarations: VAR (variable_declaration SEMI)+ | empty
  def declarations
    declarations = []
    if @current_token.type == :var
      eat :var
      while @current_token.type == :id
        declarations << variable_declaration
        eat :semi
      end
    end
    declarations.flatten
  end

  # variable declaration: ID (COMMA ID)* COLON type_spec
  def variable_declaration
    var_nodes = [Var.new(@current_token)]
    eat :id
    while @current_token.type == :comma
      eat :comma
      var_nodes << Var.new(@current_token)
      eat :id
    end

    eat :colon
    type_node = type_spec
    var_nodes.map { |v| VarDecl.new(v, type_node) }
  end

  # type_spec: INTEGER | REAL
  def type_spec
    node = Type.new(@current_token)
    if @current_token.type == :integer
      eat :integer
    else
      eat :real
    end
    node
  end

  # compound_statement: BEGIN statement_list END
  def compound_statement
    eat :begin
    nodes = statement_list
    eat :end
    root = Compound.new
    root.children = nodes
    root
  end

  # statement_list: statement | statement SEMI statement_list
  def statement_list
    results = [statement]
    while @current_token.type == :semi
      eat :semi
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
    eat :assign
    right = expr
    Assign.new(left, token, right)
  end

  # variable: ID
  def variable
    node = Var.new(@current_token)
    eat :id
    node
  end

  # empty production
  def empty
    NoOp.new
  end

  # factor : (PLUS | MINUS) factor | INTEGER_CONST | REAL_CONST | LPAREN expr RPAREN | variable
  def factor
    token = @current_token
    if token.type == :plus
      eat :plus
      UnaryOp.new(token, factor)
    elsif token.type == :minus
      eat :minus
      UnaryOp.new(token, factor)
    elsif token.type == :integer_const
      eat :integer_const
      Num.new(token)
    elsif token.type == :real_const
      eat :real_const
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
  
  # term: factor ((MUL | INTEGER_DIV | FLOAT_DIV) factor)*
  def term
    node = factor
    while [:mul, :integer_div, :float_div].include? @current_token.type
      token = @current_token
      if token.type == :mul
        eat :mul
      elsif token.type == :integer_div
        eat :integer_div
      elsif token.type == :float_div
        eat :float_div
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
