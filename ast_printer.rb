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

ASTPrinter.new(Parser.new(Lexer.new(ARGV[0]))).print

