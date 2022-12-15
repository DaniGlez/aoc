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


function exclusion_intervals(sbr, line_y)
    intervals = IntervalSet()
    for (sensor, beacon, radius) ∈ sbr
        intervals = add_exclusion_interval(intervals, sensor, radius, line_y)
    end
    intervals
end

total_span(intset::IntervalSet) = intset.items .|> span |> sum
solve_p1(sbr, line_y) = exclusion_intervals(sbr, line_y) |> total_span

sbr = parse_input("src/inputs/day15.txt")
solve_p1(sbr, 2_000_000) |> println

function _solve_p2(sbr, max_coord=4_000_000)
    grid_interval = IntervalSet(1 .. max_coord)
    for i ∈ 1:max_coord
        excl = exclusion_intervals(sbr, i) ∩ grid_interval
        if total_span(excl) < max_coord - 1
            println(total_span(excl))
            return (i, setdiff(grid_interval, excl))
        end
    end
end

function solve_p2(inputs)
    y, intset = _solve_p2(inputs)
    y + 4_000_000(intset.items[1].first + 1)
end

solve_p2(sbr) |> println



