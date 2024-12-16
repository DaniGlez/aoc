const CI = CartesianIndex
const CIs = CartesianIndices

const ENWS = (CI(0, 1), CI(-1, 0), CI(0, -1), CI(1, 0))

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

function solve_p1(M)
    E, S = ('E', 'S')
    origin = CI(findfirst(==(E), M).I..., 1)
    destination = findfirst(==(S), M)
    E_i, E_j = destination.I
    destinations = [CI(E_i, E_j, i) for i in 1:4]
    _, min_score = solve(M, (origin,), destinations)
    min_score
end

function solve(M, origins, destinations, dir_move=1)
    score = ones(Int64, (size(M)..., 4)) * typemax(Int64)
    frontier = Dict{CI{3},Int64}()
    foreach(origins) do ci
        score[ci] = 0
        enqueue!(frontier, ci => 0)
    end
    while !isempty(frontier)
        ci = dequeue!(frontier)
        if score[ci] > minimum(d -> score[d], destinations)
            continue
        end
        turn_right!(M, score, frontier, ci)
        turn_left!(M, score, frontier, ci)
        move_forward!(M, score, frontier, ci, dir_move)
    end
    score, minimum(d -> score[d], destinations)
end

turn_right!(M, score, frontier, ci) = turn!(M, score, frontier, ci, 1)
turn_left!(M, score, frontier, ci) = turn!(M, score, frontier, ci, -1)
function turn!(M, score, frontier, ci, δ)
    d_idx = ci.I[3]
    new_ci = CI(ci.I[1:2]..., mod1(d_idx + δ, 4))
    new_t = score[ci] + 1000
    if new_t < score[new_ci]
        score[new_ci] = new_t
        enqueue!(frontier, new_ci => new_t)
    end
end

function move_forward!(M, score, frontier, ci, dir_move)
    d_idx = ci.I[3]
    t = score[ci]
    new_t = t + 1
    new_ci = ci + dir_move * CI(ENWS[d_idx].I..., 0)
    if M[CI(new_ci.I[1:2]...)] == '#'
        return nothing
    end
    if new_t < score[new_ci]
        score[new_ci] = new_t
        enqueue!(frontier, new_ci => new_t)
    end
end

# TODO: avoid expanding nodes on suboptimal paths (i.e. check the fwd+bwd == score online)
function solve_p2(M)
    origin = CI(findfirst(==('E'), M).I..., 1)
    destination = findfirst(==('S'), M)
    E_i, E_j = destination.I
    destinations = [CI(E_i, E_j, i) for i in 1:4]
    score_fwd, min_score = solve(M, (origin,), destinations)
    destinations_opt = [CI(E_i, E_j, i) for i in 1:4 if score_fwd[E_i, E_j, i] == min_score]
    score_bwd, min_score_bwd = solve(M, destinations_opt, (origin,), -1)
    @assert min_score == min_score_bwd
    count(CIs(M)) do ci
        if M[ci] == '#'
            false
        else
            any(1:4) do i
                ci3 = CI(ci.I..., i)
                score_fwd[ci3] + score_bwd[ci3] == min_score
            end
        end
    end
end

begin
    M = stack(collect.(readlines("2024/inputs/day16.txt")))
    solve_p1(M) |> println
    solve_p2(M) |> println
end