using Pipe, StaticArrays
const CI₂ = CartesianIndex{2}
const N = CI₂(-1, 0)
const S = CI₂(1, 0)
const E = CI₂(0, 1)
const W = CI₂(0, -1)
const NW = CI₂(-1, -1)
const NE = CI₂(-1, 1)
const SW = CI₂(1, -1)
const SE = CI₂(1, 1)
x_pos(ci::CI₂) = ci.I[2]
y_pos(ci::CI₂) = ci.I[1]
const move_set = (
    (N, NW, NE),
    (S, SW, SE),
    (W, NW, SW),
    (E, NE, SE),
)

struct Grove{D0}
    elves::Vector{CI₂}
    gmap::Matrix{Bool}
    candidates::Matrix{UInt8}
    intents::Vector{CI₂}
    offset::CI₂
    function Grove(gmap, D0, offset=CI₂(0, 0))
        elves = [ci for ci ∈ CartesianIndices(gmap) if gmap[ci]]
        candidates = zeros(Int8, size(gmap))
        intents = similar(elves)
        new{D0}(elves, gmap, candidates, intents, offset)
    end
end

Grove(gmap) = Grove(gmap, size(gmap)[1])

function expand(g::Grove{D0}) where {D0}
    cur_size = size(g.gmap)
    cur_wh = cur_size[1]
    new_wh = cur_wh + 2D0
    new_gmap = zeros(Bool, (new_wh, new_wh))
    new_offset = g.offset + CI₂(D0, D0)
    new_gmap[CI₂(D0 + 1, D0 + 1):(CI₂(D0, D0)+CI₂(cur_size...))] .= g.gmap
    Grove(new_gmap, D0, new_offset)
end

parse_line(line) = collect(line) .|> c -> c == '#'
parse_elves(fpath="src/inputs/day23.txt") = @pipe readlines(fpath) .|> parse_line |> hcat(_...) |> transpose

function move!(g::Grove, move_idx)
    w, h = size(g.gmap)
    fill!(g.candidates, 0x0)
    for (i, elf) ∈ enumerate(g.elves)
        neighbourhood = SMatrix{3,3}(g.gmap[(elf+NW):(elf+SE)])
        g.intents[i] = elf
        sum(neighbourhood) == 1 && continue
        for j ∈ 0:3
            m, a, b = move_set[mod1(move_idx + j, 4)]
            a_n = a + CI₂(2, 2) # index in neighbourhood
            b_n = b + CI₂(2, 2)
            if sum(neighbourhood[a_n:b_n]) == 0
                g.candidates[elf+m] += 1
                g.intents[i] = elf + m
                break
            end
        end
    end
    moved = false
    expand_next = false
    # move
    for (i, elf) ∈ enumerate(g.elves)
        move = g.intents[i]
        (move == elf) && continue
        if g.candidates[move] == 0x01
            moved = true
            g.elves[i] = move
            g.gmap[move] = true
            g.gmap[elf] = false
            x_pos(move) ∈ (1, w) && (expand_next = true)
            y_pos(move) ∈ (1, h) && (expand_next = true)
        end
    end
    (expand_next, moved)
end

function enclosing_rectangle(grove::Grove)
    x_min, y_min = typemax(Int64), typemax(Int64)
    x_max, y_max = typemin(Int64), typemin(Int64)
    for elf ∈ grove.elves
        x_min = min(x_min, x_pos(elf))
        x_max = max(x_max, x_pos(elf))
        y_min = min(y_min, y_pos(elf))
        y_max = max(y_max, y_pos(elf))
    end
    (x_min, x_max), (y_min, y_max)
end

function empty_tiles(grove::Grove)
    xl, yl = enclosing_rectangle(grove)
    (xl[2] - xl[1] + 1) * (yl[2] - yl[1] + 1) - length(grove.elves)
end

function solve_p1(gmap)
    expand_next = true
    g = Grove(gmap)
    for i ∈ 1:10
        expand_next && (g = expand(g))
        expand_next, _ = move!(g, i)
    end
    empty_tiles(g)
end

parse_elves() |> solve_p1 |> println

function solve_p2(gmap)
    expand_next = true
    g = Grove(gmap)
    i = 0
    while true
        i += 1
        expand_next && (g = expand(g))
        expand_next, moved = move!(g, i)
        !moved && return i
    end
end

parse_elves() |> solve_p2 |> println