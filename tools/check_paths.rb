#!/usr/bin/env ruby
# A very short and simple script to check paths in a map file to make sure
# the DATA and TINDEX statements contain valid data, and the data is
# world readable

ARGV.each do |fl|
  lines = File.readlines(fl)
  lines.each_with_index do |line, idx|
    dnline = line.downcase
    next if dnline !~ /\A\s*data\s+/ && dnline !~ /\A\s*tindex\s+/
    # contains a data file
    path = line.split(/["']/)[1]
    unless path
      puts "#{fl}(#{idx}): strange line"
      puts "    #{idx}:#{line}"
      next
    end

    line.chomp!

    if !File.exist?(path)
      puts "#{fl}(#{idx}): not found #{path}"
      puts "    #{idx}:#{line}"
    else unless File.world_readable?(path)
           puts "#{fl}(#{idx}): is not readable #{path}"
           puts "#({idx}):#{line}"
         end
    end
  end
end
