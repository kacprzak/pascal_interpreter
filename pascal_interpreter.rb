#!/usr/bin/ruby
require_relative 'parser'

class NodeVisitor
  def visit(node)
    method_name = "visit_#{node.class.name}"
    send(method_name, node)
  end
end


class Interpreter < NodeVisitor
  def initialize(parser)
    @parser = parser
  end

  def interpret
    visit(@parser.parse)
  end

  private
  def visit_BinOp(node)
    left_value = visit(node.left)
    right_value = visit(node.right)
    left_value.public_send(node.op.value, right_value)
  end
  
  def visit_Num(node)
    node.value
  end
end


def main
  loop do
    print 'calc> '
    $stdout.flush
    text = gets.chomp
    next if text.empty?
    lexer = Lexer.new(text)
    parser = Parser.new(lexer)
    interpreter = Interpreter.new(parser)
    puts interpreter.interpret
  end
end

if __FILE__ == $0
  main
end
