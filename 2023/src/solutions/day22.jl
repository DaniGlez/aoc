const CI = CartesianIndex

function parse_line(line)
    c1, c2 = split(line, '~') .|> chunk -> parse.(Int64, split(chunk, ','))
    CI(c1...):CI(c2...) # c2 .>= c1 ∀ inputs, so no need to worry about empty ranges
end

drop(block) = block .+ CI(0, 0, -1)
lift(block) = block .+ CI(0, 0, 1)
hit_the_floor(block) = minimum(block.indices[3]) <= 0

function settle(blocks::Vector{B}) where {B}
    sort!(blocks; by=b -> minimum(b.indices[3]))
    settled_blocks = B[]
    n = length(blocks)
    # support_matrix[i,j] == true <=> block i supports block j
    floor_idx = n + 1
    support_matrix = BitMatrix(undef, (floor_idx, floor_idx))
    support_matrix .= false
    for (i, block) ∈ enumerate(blocks)
        while true
            dropped = drop(block)
            intersections = if hit_the_floor(dropped)
                [floor_idx]
            else
                findall(settled -> !isempty(settled ∩ dropped), settled_blocks)
            end
            if isempty(intersections)
                block = dropped
                continue
            else
                push!(settled_blocks, block)
                support_matrix[intersections, i] .= true
                break
            end
        end
    end
    settled_blocks, support_matrix
end

function disintegrable(A, idx)
    supported_blocks = findall(A[idx, :])
    !any(j -> sum(A[:, j]) <= 1, supported_blocks)
end

function solve_p1(blocks)
    _, A = settle(blocks)
    (n_plus_1, _) = size(A)
    sum(idx -> disintegrable(A, idx), 1:n_plus_1-1)
end

eachline("2023/inputs/input22.txt") .|> parse_line |> solve_p1

# ------ Part 2 ------
function count_dropped(support_matrix, source_idx)
    A = copy(support_matrix)
    n_dropped = 0
    queue = [source_idx]
    while !isempty(queue)
        idx = pop!(queue)
        next_bricks = findall(A[idx, :])
        A[idx, :] .= false
        for next ∈ next_bricks
            if sum(A[:, next]) == 0
                push!(queue, next)
                n_dropped += 1
            end
        end
    end
    n_dropped
end

function solve_p2(blocks)
    _, A = settle(blocks)
    (n, _) = size(A) .- 1
    sum(idx -> count_dropped(A, idx), 1:n)
end

eachline("2023/inputs/input22.txt") .|> parse_line |> solve_p2
