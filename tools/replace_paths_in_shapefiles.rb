require "georuby"
require "geo_ruby/shp"
include GeoRuby::Shp4r
require "trollop"
require "pp"

## Command line parsing action..
parser = Trollop::Parser.new do
  version "0.0.1 jay@alaska.edu"
  banner <<-EOS
  This util replaces the start of "location" fields in a 
  shapefile, used for adjusting the paths in tile indexs.

Usage:
      replace_paths_in_shapefiles.rb [options] <file1> <file2>
where [options] is:
EOS

  opt :find, "the path bit to replace",  :type => String 
  opt :replace, "the value to replace with",  :type => String
end

opts = Trollop::with_standard_exception_handling(parser) do
  o = parser.parse ARGV
  raise Trollop::HelpNeeded if ARGV.length == 0 # show help screen
  o
end


ShpFile.open(ARGV[0]) do |shp|
    shpfile = ShpFile.create(ARGV[1],ShpType::POLYGON, shp.fields)
    shpfile.transaction do |tr|
    	shp.each do |shape|
		location = shape.data["location"].sub(opts[:find], opts[:replace])
		tr.add(ShpRecord.new(shape.geometry, "location" => location))
    	end
    end
end
