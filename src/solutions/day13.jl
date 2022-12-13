parse_line(line) = Meta.parse(line) |> eval
parse_chunk(chunk) = split(strip(chunk), '\n') .|> parse_line
function parse_inputs(fpath="src/inputs/day13.txt")
    split(readchomp(fpath), "\n\n") .|> parse_chunk
end

is_ordered(a::Integer, b::Integer) = a < b
is_ordered(a::Vector, b::Integer) = is_ordered(a, [b])
is_ordered(a::Integer, b::Vector) = is_ordered([a], b)
function is_ordered(v1::Vector, v2::Vector)
    for (a, b) ∈ zip(v1, v2)
        if (a != b)
            ord = is_ordered(a, b)
            (ord !== nothing) && return ord
        end
    end
    (length(v2) > length(v1)) && return true
    (length(v2) < length(v1)) && return false
    nothing
end

solve_p1(inputs) = sum(i for (i, pair) ∈ enumerate(inputs) if is_ordered(pair...))
parse_inputs() |> solve_p1 |> println

function solve_p2(inputs)
    l = vcat(inputs...)
    dividers = ([[2]], [[6]])
    push!(l, dividers[1])
    push!(l, dividers[2])
    sort!(l; lt=is_ordered)
    findall(e -> e ∈ dividers, l) |> prod
end
parse_inputs() |> solve_p2 |> println

