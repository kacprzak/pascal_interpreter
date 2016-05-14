#!/usr/bin/ruby
require_relative 'lexer'

text = File.read(ARGV[0])
lexer = Lexer.new(text)
while true
  token = lexer.get_next_token
  puts token
  break if token.type == :eof
end


