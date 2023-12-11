const CI₂ = CartesianIndex{2}
const north = CI₂(-1, 0)
const south = CI₂(1, 0)
const west = CI₂(0, -1)
const east = CI₂(0, 1)
const CI0 = CI₂(0, 0)

const char_triplets = (
    ('|', (north, south), '│'),
    ('-', (east, west), '─'),
    ('L', (north, east), '└'),
    ('J', (north, west), '┘'),
    ('7', (south, west), '┐'),
    ('F', (east, south), '┌'),
    ('S', (south, south), 'S'), # hardcoded after ocular inspection
    ('.', (CI0, CI0), '.'),
)

struct PipeTile
    directions::NTuple{2,CI₂}
end

function PipeTile(c::Char)
    PipeTile(char_triplets[findfirst(t -> c == t[1], char_triplets)][2])
end

const start_tile = PipeTile((south, south))

function parse_map(path="2023/inputs/input10.txt", side_length=140)
    M = Matrix{PipeTile}(undef, (side_length, side_length))
    for (i, line) ∈ enumerate(eachline(path))
        M[i, :] .= map(PipeTile, collect(line))
    end
    M
end

next(pt::PipeTile, direction) = pt.directions[3-findfirst(==(-direction), pt.directions)]

pipe_tiles(M) = pipe_tiles(M, findfirst(==(start_tile), M))
function pipe_tiles(M, x)
    Δx = M[x].directions[1]
    tiles = [x]
    sizehint!(tiles, 1000)
    next_tile = PipeTile((CI0, CI0))
    while next_tile != start_tile
        x += Δx
        push!(tiles, x)
        Δx = next(M[x], Δx)
        next_tile = M[x+Δx]
    end
    tiles
end

parse_map() |> pipe_tiles |> length |> i -> (i >> 1) |> println

# ------ Part 2 ------
neighbours(x::CI₂) = x .+ (north, south, east, west)
is_inbounds(x, n) = all(in(1:n), x.I)
clamp_to_one(x) = clamp(x, -1, 1)
clamp_to_one(ci::CI₂) = CI₂(clamp_to_one.(ci.I))

@enum VertexStatus Unknown Outside

function is_connected(M, out_node, node)
    dir = node - out_node
    lr_dirs = CI₂(-dir.I[2], dir.I[1]), CI₂(dir.I[2], -dir.I[1])
    offsets = clamp_to_one.(lr_dirs .+ (dir - CI₂(1, 1)))
    left_right = out_node .+ offsets
    for (tile, rdir) ∈ zip(left_right, lr_dirs)
        -rdir ∈ M[tile].directions && return false
    end
    true
end

function clean_map!(M, pt)
    for ij ∈ CartesianIndices(M)
        ij ∈ pt || (M[ij] = PipeTile('.'))
    end
end

begin
    M = parse_map()
    pt = pipe_tiles(M)
    clean_map!(M, pt)
    n, _ = size(M)
    n₁ = n + 1
    exploration_queue = [CI₂(1, j) for j ∈ 1:n₁]
    append!(exploration_queue, [CI₂(n₁, j) for j ∈ 1:n₁])
    append!(exploration_queue, [CI₂(i, 1) for i ∈ 2:n])
    append!(exploration_queue, [CI₂(i, n₁) for i ∈ 2:n])
    V = Matrix{VertexStatus}(undef, (n, n) .+ 1) # vertex grid
    V .= Unknown
    V[1, :] .= Outside
    V[n₁, :] .= Outside
    V[:, 1] .= Outside
    V[:, n₁] .= Outside
    while length(exploration_queue) > 0
        out_node = pop!(exploration_queue)
        V[out_node] = Outside
        for node ∈ neighbours(out_node)
            is_inbounds(node, n + 1) || continue
            V[node] == Outside && continue
            ic = is_connected(M, out_node, node)
            is_connected(M, out_node, node) && push!(exploration_queue, node)
        end
    end
    c = 0
    for ij ∈ CartesianIndices(M)
        ij ∈ pt && continue
        cond = any(d -> V[CI₂(d...)+ij] == Outside, ((0, 0), (1, 0), (0, 1), (1, 1)))
        cond || (c += 1)
    end
    c
end

sum(predict, parse_line.(eachline("2023/inputs/input09.txt"))) |> println
sum(predict ∘ reverse, parse_line.(eachline("2023/inputs/input09.txt"))) |> println