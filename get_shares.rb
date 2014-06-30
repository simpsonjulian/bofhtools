#!/usr/bin/env ruby

file = ARGV.shift

contents = File.read(file).split("\n\n")

def get_attrs(lines)
  attrs = {}
  attrs['name'] = lines.first.chomp
  lines.each do |line|
    if line.match(':')
    key, value = line.split(':')
    attrs[key[1..-1]]=value.chomp[1..-1]
    end
  end
  attrs
end

def process_block(block)
  lines = block.each_line.collect
  attrs = get_attrs(lines)
  output(attrs) unless attrs['role'] == 'owner'
end

def output(entity)
  printf("%s %s %s %s %s %s %s\n", entity['name'].gsub(' ','.'),entity['domain'],entity['role'],entity['type'],entity['id'],entity['emailAddress'],entity['withLink'])
end

while contents.length != 0 
  block = contents.shift
  process_block block
end
