# https://exercism.org/tracks/ruby/exercises/locomotive-engineer

class LocomotiveEngineer
  def self.generate_list_of_wagons(*wagons)
    wagons
  end

  def self.fix_list_of_wagons(each_wagons, missing_wagons)
    first, second, *other = each_wagons

    [*other, first, second].then { |wagons|
      first, *other = wagons
      [first, *missing_wagons, *other]
    }
  end

  def self.add_missing_stops(route, **stops)
    { **route, stops: stops.values }
  end

  def self.extend_route_information(route, more_route_information)
    { **route, **more_route_information }
  end
end
