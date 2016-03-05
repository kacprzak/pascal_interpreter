#!/usr/bin/ruby
require_relative 'parser'

def main
  loop do
    print 'calc> '
    $stdout.flush
    text = gets.chomp
    next if text.empty?
    lexer = Lexer.new(text)
    parser = Parser.new(lexer)
    puts parser.parse
  end
end

if __FILE__ == $0
  main
end
