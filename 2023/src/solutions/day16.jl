const CI = CartesianIndex{2}
const CI3 = CartesianIndex{3}

ci2(ci::CI3) = CI(ci.I[1], ci.I[2])
ci3(ci::CI, d::Number) = CI3(ci.I[1], ci.I[2], d)

const up = CI(-1, 0)
const down = CI(1, 0)
const left = CI(0, -1)
const right = CI(0, 1)
const directions = (up, right, down, left)

struct Beam
    pos::CI
    dir::CI
end

Beam(ci::CI3) = Beam(ci2(ci), directions[ci3.I[3]])
Beam(i::Number, j::Number, dir::CI) = Beam(CI(i, j), dir)
CI3(b::Beam) = ci3(b.pos, findfirst(==(b.dir), directions))

advance(beam, dir) = Beam(beam.pos + dir, dir)
get_other(pair::Tuple{T,T}, x) where {T} = pair[3-findfirst(==(x), pair)]

function swap_directions(pair1, pair2, dir)
    dir ∈ pair1 ? get_other(pair1, dir) : get_other(pair2, dir)
end

to_tuple2(x) = (x, x)

function next(beam, c)
    d1, d2 = if c == '|' && beam.dir ∈ (right, left)
        (up, down)
    elseif c == '-' && beam.dir ∈ (up, down)
        (right, left)
    elseif c == '\\'
        swap_directions((left, up), (right, down), beam.dir) |> to_tuple2
    elseif c == '/'
        swap_directions((left, down), (right, up), beam.dir) |> to_tuple2
    else
        (beam.dir, beam.dir)
    end
    (advance(beam, d1), advance(beam, d2))
end


function propagate_beam(M, init=Beam(1, 1, right))
    (h, w) = size(M)
    energized = BitArray(undef, (h, w, 4))
    energized .= false
    queue = [init]
    while !isempty(queue)
        beam = pop!(queue)
        ijd = CI3(beam)
        ijd ∈ CartesianIndices(energized) || continue
        energized[ijd] ? continue : (energized[ijd] = true)
        next_beams = next(beam, M[beam.pos])
        if next_beams[1] == next_beams[2]
            push!(queue, next_beams[1])
        else
            append!(queue, next_beams)
        end
    end
    reduce(|, energized, dims=3) |> sum
end

fetch_map(path="2023/inputs/input16.txt") = stack(split(read(path, String), "\n") .|> collect, dims=1)
fetch_map() |> propagate_beam |> println

# ------ Part 2 ------

function solve_p2(M)
    (h, w) = size(M)
    m1 = maximum(i -> propagate_beam(M, Beam(i, 1, right)), 1:h)
    m2 = maximum(i -> propagate_beam(M, Beam(i, w, left)), 1:h)
    m3 = maximum(i -> propagate_beam(M, Beam(1, i, down)), 1:w)
    m4 = maximum(i -> propagate_beam(M, Beam(h, i, up)), 1:w)
    max(m1, m2, m3, m4)
end

fetch_map() |> solve_p2 |> println