#!/usr/bin/env ruby

file = ARGV.shift
@domain = ARGV.shift

contents = File.read(file).split("\n\n")

def get_attrs(lines)
  attrs = {}
  lines.each do |line|
    if line.match(':')
    key, value = line.split(':')
    attrs[key[1..-1]]=value.chomp[1..-1]
    end
  end
  attrs
end
def process_block(block)
  if block.match(/domain: #{@domain}/)
    lines = block.each_line.collect
    name = lines.first
    attrs = get_attrs(lines)


    puts "I found #{name} being all wrong"
    puts attrs.inspect
  end
end

while contents.length != 0 
  block = contents.shift
  process_block block
end

puts contents.length
