#!/usr/bin/ruby
# coding: utf-8
require_relative 'parser'
require_relative 'node_visitor'

class ASTPrinter < NodeVisitor
  SPACE = ' '
  VERTICAL = '│'
  HORIZONTAL = '─'
  VERTICAL_AND_RIGHT = '├'
  UP_AND_RIGHT = '└' 
  
  def initialize(parser)
    @parser = parser
    @indent = ""
  end

  def print
    visit(@parser.parse)
  end

  private
  def increase_indent(last_char)
    @indent += SPACE + SPACE + last_char
  end

  def decrease_indent
    @indent = @indent[0...-3]
  end

  def puts_node(node_value)
    puts @indent + HORIZONTAL + "(" + node_value + ")"

    @indent[-1,1] = VERTICAL if @indent[-1,1] == VERTICAL_AND_RIGHT
    @indent[-1,1] = SPACE if @indent[-1,1] == UP_AND_RIGHT
  end

  def visit_Program(node)
    puts_node node.name
    increase_indent UP_AND_RIGHT
    visit(node.block)
    decrease_indent
  end

  def visit_Block(node)
    puts_node "Block"
    node.declarations.each do |x|
      increase_indent VERTICAL_AND_RIGHT
      visit(x)
      decrease_indent
    end
    increase_indent UP_AND_RIGHT
    visit(node.compound_statement)
    decrease_indent
  end

  def visit_VarDecl(node)
    puts_node ":"
    increase_indent VERTICAL_AND_RIGHT
    visit(node.var_node)
    decrease_indent
    increase_indent UP_AND_RIGHT
    visit(node.type_node)
    decrease_indent
  end

  def visit_Type(node)
    puts_node node.value
  end
  
  def visit_Compound(node)
    puts_node ";"
    node.children.each_with_index do |x,i|
      if i == node.children.size - 1
        increase_indent UP_AND_RIGHT
      else
        increase_indent VERTICAL_AND_RIGHT
      end
      visit(x)
      decrease_indent
    end
  end

  def visit_NoOp(node)
    puts_node ""
  end

  def visit_Assign(node)
    puts_node node.op.value
    increase_indent VERTICAL_AND_RIGHT
    visit(node.left)
    decrease_indent
    increase_indent UP_AND_RIGHT
    visit(node.right)
    decrease_indent    
  end

  def visit_Var(node)
    puts_node node.value
  end
  
  def visit_BinOp(node)
    puts_node node.op.value
    increase_indent VERTICAL_AND_RIGHT
    visit(node.left)
    decrease_indent
    increase_indent UP_AND_RIGHT
    visit(node.right)
    decrease_indent
  end

  def visit_UnaryOp(node)
    puts_node node.op.value
    increase_indent UP_AND_RIGHT
    visit(node.child)
    decrease_indent
  end
  
  def visit_Num(node)
    puts_node node.value.to_s
  end
end

text = File.read(ARGV[0])
ASTPrinter.new(Parser.new(Lexer.new(text))).print

