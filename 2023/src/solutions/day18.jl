const CI = CartesianIndex
const U = CI(-1, 0)
const R = CI(0, 1)
const L = CI(0, -1)
const D = CI(1, 0)
const c2ci = Dict('U' => U, 'R' => R, 'L' => L, 'D' => D)

parse_line(line) = c2ci[line[1]], parse(Int64, line[3:4]), split(line, "(#")[2][1:6]

fetch_input(path="2023/inputs/input18.txt") = eachline(path) .|> parse_line
fetch_input()

function make_trench(moves)
    x = CI(0, 0)
    visited = [x]
    sizehint!(visited, 4096)
    for (move, n) ∈ moves
        for _ ∈ 1:n
            x += move
            push!(visited, x)
        end
    end
    i_min = minimum(ij -> ij.I[1], visited)
    j_min = minimum(ij -> ij.I[2], visited)
    visited .- CI(i_min, j_min) .+ CI(1, 1)
end

@enum CellStatus Unknown Outside Inside

neighbours(x) = x .+ (U, L, D, R)
function capacity(trench; area_weighting=nothing)
    h = maximum(ij -> ij.I[1], trench)
    w = maximum(ij -> ij.I[2], trench)
    M = Matrix{CellStatus}(undef, (h, w))
    M .= Unknown
    M[trench] .= Inside
    candidates = CI{2}[]
    for i ∈ 1:h
        push!(candidates, CI(i, 0))
        push!(candidates, CI(i, w + 1))
    end
    for j ∈ 1:w
        push!(candidates, CI(0, j))
        push!(candidates, CI(h + 1, j))
    end
    while !isempty(candidates)
        x = pop!(candidates)
        for y ∈ neighbours(x)
            y ∈ CartesianIndices(M) || continue
            M[y] == Unknown || continue
            M[y] = Outside
            push!(candidates, y)
        end
    end
    isnothing(area_weighting) && return h * w - sum(M .== Outside)
    i_dists, j_dists = diff.(area_weighting)
    A = kron(i_dists, j_dists')
    sum(A .* (M .!= Outside))
end

fetch_input() |> make_trench |> capacity

# ------ Part 2 ------+

const d2dir = Dict('3' => U, '0' => R, '2' => L, '1' => D)
new_instruction(rgb) = d2dir[rgb[6]], parse(Int64, rgb[1:5], base=16)
new_instruction(inst::Tuple) = new_instruction(inst[3])

space_splitting_indexes(trench) = idx -> begin
    arr0 = unique(trench .|> ci -> ci.I[idx])
    arr1 = arr0 .+ 1
    unique(vcat(arr0, arr1)) |> sort
end

function project_trench(trench)
    ij = (1, 2) .|> space_splitting_indexes(trench)
    projs = ij .|> idx_arr -> Dict(idx => k for (k, idx) ∈ enumerate(idx_arr))
    mapped_trench = [CI(projs[1][ij.I[1]], projs[2][ij.I[2]]) for ij ∈ trench]
    fill_trench_gaps(mapped_trench), ij
end

function make_trench_2(moves)
    x = CI(0, 0)
    visited = [x]
    sizehint!(visited, 1024)
    for (move, n) ∈ moves
        x += n * move
        push!(visited, x)
    end
    i_min = minimum(ij -> ij.I[1], visited)
    j_min = minimum(ij -> ij.I[2], visited)
    visited .- CI(i_min, j_min) .+ CI(1, 1)
end

function fill_trench_gaps(trench)
    new_trench = eltype(trench)[]
    for (p, q) ∈ zip(trench[1:end-1], trench[2:end])
        Δ = CI(clamp.((q - p).I, -1, 1)...)
        x = p
        while x != q
            push!(new_trench, x)
            x += Δ
        end
    end
    new_trench
end

cap1(x) = CI(clamp.(x.I, -1, 1)...)

function solve_p2(instructions)
    trench, ij = (new_instruction.(instructions) |> make_trench_2 |> project_trench)
    capacity(trench; area_weighting=ij)
end

fetch_input() |> solve_p2

# ------ debugging ------

const cell2char = Dict(Outside => '.', Unknown => '*', Inside => '#')
function show_trench_map(M)
    for row ∈ eachrow(M)
        println(map(c -> cell2char[c], row) |> join)
    end
end

