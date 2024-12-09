#!/usr/bin/env ruby
require 'json'

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele = nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end

  def to_coordinate_array
    coordinate = [@lon, @lat]
    coordinate << @ele unless @ele.nil?
    coordinate
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def to_line_coordinates
    @coordinates.map(&:to_coordinate_array)
  end
end

class Track
  def initialize(segments, name = nil)
    @name = name
    @segments = segments.map { |segment| TrackSegment.new(segment) }
  end

  def to_feature_hash
    feature = {
      "type" => "Feature",
      "geometry" => {
        "type" => "MultiLineString",
        "coordinates" => @segments.map(&:to_line_coordinates)
      }
    }

    if @name
      feature["properties"] = { "title" => @name }
    end

    feature
  end

  def get_track_json
    JSON.generate(to_feature_hash)
  end
end

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele = nil, name = nil, type = nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def to_feature_hash
    coordinates = [@lon, @lat]
    coordinates << @ele unless @ele.nil?

    feature = {
      "type" => "Feature",
      "geometry" => {
        "type" => "Point",
        "coordinates" => coordinates
      }
    }

    if @name || @type
      properties = {}
      properties["title"] = @name if @name
      properties["icon"] = @type if @type
      feature["properties"] = properties
    end

    feature
  end

  def get_waypoint_json(_indent = 0)
    JSON.generate(to_feature_hash)
  end
end

class World
  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(feature)
    @features << feature
  end

  def to_geojson(_indent = 0)
    fc = {
      "type" => "FeatureCollection",
      "features" => @features.map { |f|
        if f.is_a?(Track)
          f.to_feature_hash
        elsif f.is_a?(Waypoint)
          f.to_feature_hash
        else
          # If other feature types are introduced in the future
          {}
        end
      }
    }

    JSON.generate(fc)
  end
end

def main
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")

  ts1 = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46),
  ]

  ts2 = [
    Point.new(-121, 45),
    Point.new(-121, 46)
  ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson
end

if __FILE__ == $0
  main
end