#!/usr/bin/env ruby

class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |seg|
      segment_objects.append(TrackSegment.new(seg))
    end

    @segments = segment_objects
  end

  def get_track_json()
    json = '{"type": "Feature", '

    if @name != nil
      json += '"properties": {"title": "' + @name + '"},'
    end

    json += '"geometry": {"type": "MultiLineString","coordinates": ['

    # Loop through all the segment objects
    @segments.each_with_index do |seg, i|
      if i > 0
        json += ","
      end

      json += '['
      typescript_json = ''
      
      # Loop through all the coordinates in the segment
      seg.coordinates.each do |cord|
        if typescript_json != ''
          typescript_json += ','
        end

        # Add the coordinate
        typescript_json += "[#{cord.lon},#{cord.lat}"

        if cord.ele != nil
          typescript_json += ",#{cord.ele}"
        end

        typescript_json += ']'
      end
      
      json += typescript_json + ']'
    end

    json + ']}}'
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele = nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint
  attr_reader :point, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @point = Point.new(lon, lat, ele)
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    json = '{"type": "Feature","geometry": {"type": "Point","coordinates": ['
    json += "#{@point.lon},#{@point.lat}"

    if point.ele != nil
      json += ",#{@point.ele}"
    end

    json += ']},'

    if name != nil or type != nil
      json += '"properties": {'

      if name != nil
        json += '"title": "' + @name + '"'
      end

      if type != nil
        if name != nil
          json += ','
        end

        json += '"icon": "' + @type + '"'
      end

      json += '}'
    end

    json += "}"
  end
end

class World
  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(feat)
    @features.append(feat)
  end

  def to_geojson(indent = 0)
    geojson = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feat,i|
      if i != 0
        geojson +=","
      end

      if feat.class == Track
        geojson += feat.get_track_json
      elsif feat.class == Waypoint
        geojson += feat.get_waypoint_json
      end
    end

    geojson + "]}"
  end
end

def main()
  way = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  way2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  track_seg1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46)
  ]

  track_seg2 = [Point.new(-121, 45), Point.new(-121, 46)]

  track_seg3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5)
  ]

  track = Track.new([track_seg1, track_seg2], "track 1")
  track2 = Track.new([track_seg3], "track 2")

  world = World.new("My Data", [way, way2, track, track2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end