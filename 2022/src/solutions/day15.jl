using Intervals

const CI = CartesianIndex
l₁(ci::CI) = abs(ci.I[1]) + abs(ci.I[2])
function parse_line(line)
    re = r"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)"
    sx, sy, bx, by = parse.(Int64, match(re, line).captures)
    sensor = CI(sy, sx)
    beacon = CI(by, bx)
    exclusion_radius = l₁(sensor - beacon)
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

# this is slow, see below
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

# ------------------------------
# And now, the cheesiest solution of the year so far
clamp_to_square(x) = clamp(x, -1, 1)
clamp_to_square(ci::CartesianIndex{2}) = CartesianIndex(clamp_to_square.(ci.I)...)
using DataStructures, StaticArrays
const CI2 = CartesianIndex{2}
struct Sensor
    position::CI2
    exclusion_radius::Int64
end
Base.in(ci::CartesianIndex{2}, s::Sensor) = l₁(ci - s.position) <= s.exclusion_radius

struct Canyon
    start_point::CI2
    end_point::CI2
end
normal(c::Canyon) = clamp_to_square(c.end_point - c.start_point)
function Base.intersect(c1::Canyon, c2::Canyon)
    n1 = normal(c1)
    n2 = normal(c2)
    s1 = c1.start_point
    s2 = c2.start_point
    Δy = s2.I[1] - s1.I[1]
    Δx = s2.I[2] - s1.I[2]
    A = @SMatrix [n1[1] (-n2[1]); n1[2] (-n2[2])]
    b = @SVector [Δy, Δx]
    d = SVector{2,Int64}(inv(A) * b)
    p1 = s1 + d[1] * n1
    p2 = s2 + d[2] * n2
    (p1 == p2) && return p1
    nothing
end

function parse_line_alt(line)
    re = r"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)"
    sx, sy, bx, by = parse.(Int64, match(re, line).captures)
    sensor = CI(sy, sx)
    beacon = CI(by, bx)
    exclusion_radius = l₁(sensor - beacon)
    Sensor(sensor, exclusion_radius)
end

function parse_alt(fpath="src/inputs/day15.txt")
    sensors = readlines(fpath) .|> parse_line_alt
    SVector{length(sensors)}(sensors)
end

sensors_to_canyon(s1s2) = sensors_to_canyon(s1s2...)
function sensors_to_canyon(s1, s2)
    if s2.position.I[1] > s1.position.I[1]
        s1, s2 = s2, s1 # s1 is higher than s2
    end
    s1_to_the_left = s2.position.I[2] > s1.position.I[2]
    dirs = (CI(0, -1), CI(-1, 0))
    dirs = s1_to_the_left ? (CI(0, 1), CI(-1, 0)) : (CI(0, -1), CI(-1, 0))
    if s1.exclusion_radius <= s2.exclusion_radius
        r = s1.exclusion_radius + 1
        c1 = s1.position + r * dirs[1]
        c2 = s1.position + r * dirs[2]
    else
        r = s2.exclusion_radius + 1
        c1 = s2.position - r * dirs[1]
        c2 = s2.position - r * dirs[2]
    end
    Canyon(c1, c2)
end

function solve_p2(sensors, grid_wh=4_000_000)
    examined_pairs = Stack{Tuple{Sensor,Sensor}}()
    candidate_pairs = Stack{Tuple{Sensor,Sensor}}()
    for s_a ∈ sensors
        for s_b ∈ sensors
            p = (s_a, s_b)
            if (p ∉ examined_pairs)
                push!(examined_pairs, p)
                push!(examined_pairs, reverse(p))
                centers_dist = l₁(s_a.position - s_b.position)
                if centers_dist == (s_a.exclusion_radius + s_b.exclusion_radius + 2)
                    push!(candidate_pairs, p)
                end
            end
        end
    end
    (length(candidate_pairs) == 2) || error("Code the pairwise intersections u lazy bum")
    canyons = sensors_to_canyon.(candidate_pairs)
    p = canyons[1] ∩ canyons[2]
    p[1] + grid_wh * p[2]
end

parse_alt() |> solve_p2 |> println
