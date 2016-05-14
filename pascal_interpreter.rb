#!/usr/bin/ruby
require_relative 'parser'
require_relative 'node_visitor'

class Interpreter < NodeVisitor
  attr_accessor :global_scope
  
  def initialize(parser)
    @parser = parser
    @global_scope = {}
  end

  def interpret
    visit(@parser.parse)
    nil
  end

  private
  def visit_Compound(node)
    node.children.each do |x|
      visit(x)
    end
  end

  def visit_NoOp(node)
  end

  def visit_Assign(node)
    @global_scope[node.left.value.downcase] = visit(node.right)
  end

  def visit_Var(node)
    @global_scope[node.value.downcase]
  end
  
  def visit_BinOp(node)
    left_value = visit(node.left)
    right_value = visit(node.right)
    left_value.public_send(node.op.value, right_value)
  end

  def visit_UnaryOp(node)
    op = node.op.type
    if op == :plus
      +visit(node.child)
    elsif op == :minus
      -visit(node.child)
    end
  end
  
  def visit_Num(node)
    node.value
  end
end


def interactive_interpreter
  scope = {}
  loop do
    print 'pas> '
    $stdout.flush
    text = gets.chomp
    
    next if text.empty?
    break if text == 'q'
    if text[-1] != '.'
      text = "BEGIN #{text} END."
    end
    
    lexer = Lexer.new(text)
    parser = Parser.new(lexer)
    interpreter = Interpreter.new(parser)
    interpreter.global_scope = scope
    interpreter.interpret
    scope = interpreter.global_scope
    puts scope
  end  
end

def main
  if ARGV.length == 0
    interactive_interpreter
  else
    text = File.read(ARGV[0])
    interpreter = Interpreter.new(Parser.new(Lexer.new(text)))
    interpreter.interpret
    puts interpreter.global_scope
  end  
end

if __FILE__ == $0
  main
end
