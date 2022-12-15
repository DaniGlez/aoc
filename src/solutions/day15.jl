using Intervals

const CI = CartesianIndex

l₁(ci::CI) = abs(ci.I[1]) + abs(ci.I[2])
l₁(a, b) = l₁(a - b)
function parse_line(line)
    re = r"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)"
    sx, sy, bx, by = parse.(Int64, match(re, line).captures)
    sensor = CI(sy, sx)
    beacon = CI(by, bx)
    exclusion_radius = l₁(sensor, beacon)
    (sensor, beacon, exclusion_radius)
end
parse_input(fpath="src/inputs/day15.txt") = readlines(fpath) .|> parse_line

function add_exclusion_interval(intervals, sensor, radius, y)
    r_line = radius - abs(sensor.I[1] - y)
    if r_line <= 0
        return intervals
    end
    x = sensor.I[2]
    exclusion_interval = (x - r_line) .. (x + r_line)
    intervals ∪ IntervalSet(exclusion_interval)
end

function solve_p1(sbr, line_y)
    intervals = IntervalSet()
    for (sensor, beacon, radius) ∈ sbr
        intervals = add_exclusion_interval(intervals, sensor, radius, line_y)
    end
    intervals.items .|> span |> sum
end

sbr = parse_input("src/inputs/day15.txt")
solve_p1(sbr, 2_000_000) |> println


