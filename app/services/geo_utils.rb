# frozen_string_literal: true

module GeoUtils
  EARTH_RADIUS_M = 6_371_000

  module_function

  def distance_m(lat1, lng1, lat2, lng2)
    d_lat = to_rad(lat2 - lat1)
    d_lng = to_rad(lng2 - lng1)
    a = Math.sin(d_lat / 2)**2 +
        Math.cos(to_rad(lat1)) * Math.cos(to_rad(lat2)) * Math.sin(d_lng / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    EARTH_RADIUS_M * c
  end

  def to_rad(deg)
    deg * Math::PI / 180.0
  end
end
