#!/usr/bin/env ruby

class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
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
    @segments.each_with_index do |s, index|
      if index > 0
        json += ","
      end
      json += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |cord|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += "[#{cord.lon},#{cord.lat}"
        if cord.ele != nil
          tsj += ",#{cord.ele}"
        end
        tsj += ']'
      end
      json += tsj + ']'
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
    return json
  end
end

class World
  def initialize(name, things)
    @name = name
    @features = things
  end
  def add_feature(f)
    @features.append(t)
  end

  def to_geojson(indent=0)

    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
        if f.class == Track
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
      end
    end
    s + "]}"
  end
end

def main()
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

