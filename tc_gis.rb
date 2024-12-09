require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase
  # Helper method to parse JSON
  def parse_json(string)
    JSON.parse(string)
  end

  # Helper method to create a waypoint
  def create_waypoint(lon, lat, alt = nil, title = nil, icon = nil)
    Waypoint.new(lon, lat, alt, title, icon)
  end

  # Helper method to create a track
  def create_track(points, title)
    Track.new(points, title)
  end

  def test_waypoints
    w = create_waypoint(-121.5, 45.5, 30, "home", "flag")
    expected = parse_json('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    assert_equal(parse_json(w.get_waypoint_json), expected)

    w = create_waypoint(-121.5, 45.5, nil, nil, "flag")
    expected = parse_json('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    assert_equal(parse_json(w.get_waypoint_json), expected)

    w = create_waypoint(-121.5, 45.5, nil, "store", nil)
    expected = parse_json('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    assert_equal(parse_json(w.get_waypoint_json), expected)
  end

  def test_tracks
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46) ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    t = create_track([ts1, ts2], "track 1")
    expected = parse_json('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    assert_equal(parse_json(t.get_track_json), expected)

    t = create_track([ts3], "track 2")
    expected = parse_json('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    assert_equal(parse_json(t.get_track_json), expected)
  end

  def test_world
    w1 = create_waypoint(-121.5, 45.5, 30, "home", "flag")
    w2 = create_waypoint(-121.5, 45.6, nil, "store", "dot")

    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46) ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    t1 = create_track([ts1, ts2], "track 1")
    t2 = create_track([ts3], "track 2")

    world = World.new("My Data", [w1, w2, t1, t2])

    expected = parse_json('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    assert_equal(parse_json(world.to_geojson), expected)
  end
end