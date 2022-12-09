using Pipe, Accessors, StaticArrays

# inputs
const move_d = Dict(
    'U' => SA[0, 1],
    'D' => SA[0, -1],
    'L' => SA[-1, 0],
    'R' => SA[1, 0]
)
pline(line) = (move_d[line[1]], parse(Int64, line[3:end]))
input_moves() =
    open("src/inputs/day9.txt") do f
        return @pipe readlines(f) .|> pline
    end

# example
const EXAMPLE = """R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2"""
example_moves() = split(EXAMPLE, '\n') .|> pline

# common
l∞(x) = maximum(abs.(x))
clamp_step(Δ) = l∞(Δ) > 1 ? clamp.(Δ, -1, 1) : SA[0, 0]
pull_segment(leading, trailing) = trailing + clamp_step(leading - trailing)

function solve_p1(moves)
    starting_point = @SArray [0, 0]
    rhead = starting_point
    rtail = starting_point
    visited = Set((starting_point,))
    println(visited)
    for (dir, n) ∈ moves
        for _ ∈ 1:n
            rhead += dir
            rtail = pull_segment(rhead, rtail)
            @assert maximum(abs.(rhead - rtail)) <= 1
            push!(visited, rtail)
        end
    end
    length(visited)
end

input_moves() |> solve_p1

# Part 2: no step on snek
using Base.Cartesian: @nexprs
@generated function move_snek!(snek::MVector{N}, dir) where {N}
    quote
        snek[1] += dir
        @nexprs $(N - 1) i -> snek[i+1] = pull_segment(snek[i], snek[i+1])
    end
end

solve_p2(moves) = solve_p2(moves, Val(10))
function solve_p2(moves, ::Val{N}) where {N}
    starting_point = SA[0, 0]
    snek = MVector{N}([starting_point for _ ∈ 1:N])
    visited = Set{SVector{2,Int64}}()
    push!(visited, starting_point)
    for (dir, n) ∈ moves
        for _ ∈ 1:n
            move_snek!(snek, dir)
            push!(visited, snek[end])
        end
    end
    length(visited)
end
input_moves() |> solve_p2