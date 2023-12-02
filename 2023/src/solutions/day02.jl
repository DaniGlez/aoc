# ------ Part 1 ------

function parse_move(move::AbstractString)
    function fetch_color(re)
        m = match(re, move)
        isnothing(m) && return 0
        parse(Int64, m.captures[1])
    end
    fetch_color.((r"(\d+) red", r"(\d+) green", r"(\d+) blue"))
end

function is_valid_move_p1(move::AbstractString)
    r, g, b = parse_move(move)
    r <= 12 && g <= 13 && b <= 14
end

function is_possible_p1(s::AbstractString)
    s_moves = split(s, ": ")[2]
    for move ∈ split(s_moves, ';')
        is_valid_move_p1(move) || return false
    end
    true
end

sum(
    ((i, line),) -> is_possible_p1(line) ? i : 0,
    enumerate(eachline("2023/inputs/input02.txt"))
) |> println

# ------ Part 2 ------

function mincubes_power(s::AbstractString)
    s_moves = split(s, ": ")[2]
    cubes = (0, 0, 0)
    for move ∈ split(s_moves, ';')
        rgb = parse_move(move)
        cubes = maximum.(zip(rgb, cubes))
    end
    prod(cubes)
end

sum(mincubes_power, eachline("2023/inputs/input02.txt")) |> println