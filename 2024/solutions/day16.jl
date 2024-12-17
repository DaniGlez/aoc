const CI = CartesianIndex
const CIs = CartesianIndices

const ENWS = (CI(0, 1), CI(-1, 0), CI(0, -1), CI(1, 0))

ci2_to_ci3(ci2::CI{2}, i) = CI(ci2.I[1], ci2.I[2], mod1(i, 4))
ci3_to_ci2(ci3::CI{3}) = CI(ci3.I[1], ci3.I[2])

# Poor-man's priority queue
function dequeue!(d::Dict)
    v = minimum(values(d))
    for k in keys(d)
        if d[k] == v
            delete!(d, k)
            return k
        end
    end
end

function enqueue!(d::Dict, kv)
    k, v = kv
    d[k] = v
end

function solve(M, origins, destinations, dir_move=1)
    score = ones(Int64, (size(M)..., 4)) * typemax(Int64)
    frontier = Dict{CI{3},Int64}()
    foreach(origins) do ijk
        score[ijk] = 0
        enqueue!(frontier, ijk => 0)
    end
    while !isempty(frontier)
        ijk = dequeue!(frontier)
        if score[ijk] > minimum(d -> score[d], destinations)
            continue
        end
        turn_right!(M, score, frontier, ijk)
        turn_left!(M, score, frontier, ijk)
        move_forward!(M, score, frontier, ijk, dir_move)
    end
    score, minimum(d -> score[d], destinations)
end

function add_node!(score, frontier, ijk, t)
    if t < score[ijk]
        score[ijk] = t
        enqueue!(frontier, ijk => t)
    end
end

turn_right!(_, score, frontier, ijk) = turn!(score, frontier, ijk, 1)
turn_left!(_, score, frontier, ijk) = turn!(score, frontier, ijk, -1)
function turn!(score, frontier, ijk, δ)
    new_ci = ci2_to_ci3(ci3_to_ci2(ijk), ijk.I[3] + δ)
    add_node!(score, frontier, new_ci, score[ijk] + 1000)
end

function move_forward!(M, score, frontier, ijk, dir_move)
    d_idx = ijk.I[3]
    t = score[ijk]
    next = ijk + dir_move * CI(ENWS[d_idx].I..., 0)
    if M[ci3_to_ci2(next)] != '#'
        add_node!(score, frontier, next, t + 1)
    end
end

# TODO: avoid expanding nodes on suboptimal paths (i.e. check the fwd+bwd == score online)
begin
    M = permutedims(stack(collect.(readlines("2024/inputs/day16.txt"))))
    E_i, E_j = findfirst(==('E'), M).I
    origin = ci2_to_ci3(findfirst(==('S'), M), 1)
    destinations = [CI(E_i, E_j, i) for i in 1:4]
    score_fwd, min_score = solve(M, (origin,), destinations)
    destinations_opt = filter(ijk -> score_fwd[ijk] == min_score, destinations)
    score_bwd, min_score_bwd = solve(M, destinations_opt, (origin,), -1)
    @assert min_score == min_score_bwd
    (
        min_score,
        count(CIs(M)) do ij
            M[ij] != '#' && any(1:4) do k
                ijk = ci2_to_ci3(ij, k)
                score_fwd[ijk] + score_bwd[ijk] == min_score
            end
        end
    )
end