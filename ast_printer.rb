#!/usr/bin/ruby
# coding: utf-8
require_relative 'parser'
require_relative 'node_visitor'

class ASTPrinter < NodeVisitor
  def initialize(parser)
    @parser = parser
    @indent = ""
  end

  def print
    visit(@parser.parse)
  end

  private
  def increase_indent(text)
    @indent += text
  end

  def decrease_indent(num_of_chars)
    @indent = @indent[0...-num_of_chars]
  end

  def puts_node(node_value)
    puts @indent + "─(" + node_value + ")"

    @indent[-1,1] = "│" if @indent[-1, 1] == "├"
    @indent[-1,1] = " " if @indent[-1, 1] == "└"
  end

  def visit_BinOp(node)
    puts_node node.op.value
    increase_indent "  ├"
    visit(node.left)
    decrease_indent 3
    increase_indent "  └"
    visit(node.right)
    decrease_indent 3
  end
  
  def visit_Num(node)
    puts_node node.value.to_s
  end
end

ASTPrinter.new(Parser.new(Lexer.new(ARGV[0]))).print

