#!/usr/bin/env ruby

require "optparse"
require "nokogiri"

# Creates a sleepyhammer logo as an Eagle package in a library.  Reads
# an existing library and either replaces an existing package or
# creates a new one.

# The eyelid is an arc of an ellipse.  The lashes start on the eyelid,
# and end on an ellipse with the same center but slightly different
# major/minor axes.

optparse = OptionParser.new do |op|
  op.banner = "Usage: #{$0} library package_name [layer] [mm]"

  op.on('-h', '--help', "Show this help") do
    puts op
    exit
  end
end

begin
  argv = optparse.parse(ARGV)
rescue OptionParser::ParseError => ex
  $stderr.puts ex
  $stderr.puts optparse
  exit 1
end

library = argv.shift
package_name = argv.shift
layer = argv.shift || "21"
mm = (argv.shift || 7.05).to_f

if !library || !package_name || !argv.empty?
  $stderr.puts optparse
  exit 1
end

SCALE = mm/92.0

# Center of the eyelid and eyelash ellipses:

CENTER = [0, -45 * SCALE]

# Eyelid major/minor axis lengths:

EYE_MAJOR = 92.0 * SCALE
EYE_MINOR = EYE_MAJOR * 2/3

# Width of the eyelid line:

EYE_WIDTH = 16.3 * SCALE

# Eyelid is an arc 109 degrees wide:

EYE_ANGLE = 109.0

# Eyelash major/minor axis lengths:

EYELASH_MAJOR = EYE_MAJOR * 1.24
EYELASH_MINOR = EYE_MINOR * 1.44

# Width of the eyelash lines:

EYELASH_WIDTH = 14.1 * SCALE

# How many eyelashes to draw:

EYELASH_COUNT = 6

# Angle from left lash to right lash.

EYELASH_ANGLE = 98.0

doc = File.open(library) {|f| Nokogiri::XML(f)}

package = doc.css("package[name='#{package_name}']").first
if package
  package.children.each do |child|
    child.remove
  end
else
  package = Nokogiri::XML::Node.new("package", doc).tap do |package|
    package["name"] = package_name
    package["description"] = "SleepyHammer logo"
  end

  doc.css("packages").first << package
  doc.css("packages").first << Nokogiri::XML::Text.new("\n", doc)
end

package << Nokogiri::XML::Text.new("\n", doc)

# Eyelid:

segments = 10
0.upto(segments - 1) do |n|
  left_angle = (90 - EYE_ANGLE/2) + EYE_ANGLE / segments * n
  left_angle *= Math::PI / 180

  right_angle = (90 - EYE_ANGLE/2) + EYE_ANGLE / segments * (n + 1)
  right_angle *= Math::PI / 180

  package << Nokogiri::XML::Node.new("wire", doc).tap do |wire|
    wire["x1"] = CENTER[0] + EYE_MAJOR * Math.cos(left_angle)
    wire["y1"] = -(CENTER[1] + EYE_MINOR * Math.sin(left_angle))
    wire["x2"] = CENTER[0] + EYE_MAJOR * Math.cos(right_angle)
    wire["y2"] = -(CENTER[1] + EYE_MINOR * Math.sin(right_angle))
    wire["width"] = EYE_WIDTH.to_s
    wire["layer"] = layer
  end
  package << Nokogiri::XML::Text.new("\n", doc)
end

# Eye lashes:

0.upto(EYELASH_COUNT - 1) do |n|
  angle = (90 - EYELASH_ANGLE/2) + EYELASH_ANGLE / (EYELASH_COUNT - 1) * n
  angle *= Math::PI / 180
  
  start_point = [CENTER[0] + EYE_MAJOR * Math.cos(angle),
                 CENTER[1] + EYE_MINOR * Math.sin(angle)]
  
  end_point = [CENTER[0] + EYELASH_MAJOR * Math.cos(angle),
               CENTER[1] + EYELASH_MINOR * Math.sin(angle)]
  
  package << Nokogiri::XML::Node.new("wire", doc).tap do |wire|
    wire["x1"] = start_point[0]
    wire["y1"] = -start_point[1]
    wire["x2"] = end_point[0]
    wire["y2"] = -end_point[1]
    wire["width"] = EYELASH_WIDTH.to_s
    wire["layer"] = layer
  end
  package << Nokogiri::XML::Text.new("\n", doc)
end

puts doc
