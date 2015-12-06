#!/usr/bin/env ruby

require "nokogiri"

# Creates an SVG sleepyhammer logo.  The eyelid is an arc of an
# ellipse.  The lashes start on the eyelid, and end on an ellipse with
# the same center but slightly different major/minor axes.

# Reads an existing (Inkscape) file "sleepyhammer.svg" and replaces
# the "new" layer with the logo.

# Center of the eyelid and eyelash ellipses:

CENTER = [311.0, 297.8468]

# Eyelid major/minor axis lengths:

EYE_MAJOR = 92.0
EYE_MINOR = EYE_MAJOR * 2/3

# Width of the eyelid line:

EYE_WIDTH = 16.3

# Eyelid is an arc 109 degrees wide:

EYE_ANGLE = 109.0

# Eyelash major/minor axis lengths:

EYELASH_MAJOR = EYE_MAJOR * 1.24
EYELASH_MINOR = EYE_MINOR * 1.44

# Width of the eyelash lines:

EYELASH_WIDTH = 14.1

# How many eyelashes to draw:

EYELASH_COUNT = 6

# Angle from left lash to right lash.

EYELASH_ANGLE = 98.0

COLOR = "#1587d1"

doc = File.open("sleepyhammer.svg") {|f| Nokogiri::XML(f)}

doc.css("#new").each do |g|
  g.children.each do |child|
    child.remove
  end

  # Eyelid:

  g << Nokogiri::XML::Node.new("path", doc).tap do |e|
    e["style"] = "fill:none;stroke:#{COLOR};stroke-width:#{EYE_WIDTH};stroke-linecap:round"
    angle = (EYE_ANGLE / 2.0) * Math::PI / 180
    left = [CENTER[0] + EYE_MAJOR * Math.cos(Math::PI/2 - angle),
            CENTER[1] + EYE_MINOR * Math.sin(Math::PI/2 - angle)]
    right = [CENTER[0] + EYE_MAJOR * Math.cos(Math::PI/2 + angle),
             CENTER[1] + EYE_MINOR * Math.sin(Math::PI/2 + angle)]

    e["d"] = "M #{left.join(",")} A #{EYE_MAJOR},#{EYE_MINOR} 0 0 1 #{right.join(",")}"
  end

  # Eye lashes:

  0.upto(EYELASH_COUNT - 1) do |n|
    angle = (90 - EYELASH_ANGLE/2) + EYELASH_ANGLE / (EYELASH_COUNT - 1) * n
    angle *= Math::PI / 180

    start_point = [CENTER[0] + EYE_MAJOR * Math.cos(angle),
                   CENTER[1] + EYE_MINOR * Math.sin(angle)]

    end_point = [CENTER[0] + EYELASH_MAJOR * Math.cos(angle),
                 CENTER[1] + EYELASH_MINOR * Math.sin(angle)]
  
    g << Nokogiri::XML::Node.new("path", doc).tap do |e|
      e["style"] = "fill:none;stroke:#{COLOR};stroke-width:#{EYELASH_WIDTH};stroke-linecap:round"
      e["d"] = "M #{start_point.join(",")} #{end_point.join(",")}"
    end
  end
end

puts doc
