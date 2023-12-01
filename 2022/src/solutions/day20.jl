using Pipe

parse_input(fpath="src/inputs/day20.txt") = @pipe readlines(fpath) .|> parse(Int16, _)
example_input = Int16[1, 2, -3, 3, -2, 0, 4]

mutable struct WrappyVector{N,T}
    values::Vector{T}
    successors::Vector{T}
    predecessors::Vector{T}
    zero_idx::T
    function WrappyVector(values::Vector{T}) where {T}
        N = length(values)
        successors = T.(mod1.((2:(N+1)), N))
        predecessors = T.(mod1.((N:(2N-1)), N))
        zero_idx = findfirst(v -> v == 0, values)
        new{N,T}(values, successors, predecessors, zero_idx)
    end
end

s_or_p(w::WrappyVector, s) = (s < 0) ? w.predecessors : w.successors
neighbours(w, i) = (w.predecessors[i], w.successors[i])

function jump(vector, i, n_jumps)
    for _ ∈ 1:n_jumps
        i = vector[i]
    end
    i
end

function shift!(w::WrappyVector{N,T}) where {N,T}
    for (i, v) ∈ enumerate(w.values)
        v == 0 && continue
        s = sign(v)
        m = abs(v)
        side = s_or_p(w, s)
        rem_shift = m % (N - 1)
        j = jump(side, i, rem_shift)
        p_i, s_i = neighbours(w, i)
        p_j, s_j = neighbours(w, j)
        w.successors[p_i] = s_i
        w.predecessors[s_i] = p_i
        if (s > 0)
            w.successors[j] = i
            w.predecessors[i] = j
            w.successors[i] = s_j
            w.predecessors[s_j] = i
        else
            w.successors[p_j] = i
            w.predecessors[i] = p_j
            w.successors[i] = j
            w.predecessors[j] = i
        end
    end
end

function grove_coordinates(w)
    a = jump(w.successors, w.zero_idx, 1000)
    b = jump(w.successors, a, 1000)
    c = jump(w.successors, b, 1000)
    (a, b, c) .|> i -> w.values[i]
end

function solve_p1(nums)
    w = WrappyVector(nums)
    shift!(w)
    grove_coordinates(w) |> sum
end

parse_input() |> solve_p1

function solve_p2(nums, decription_key=811589153)
    w = WrappyVector(nums * decription_key)
    for _ ∈ 1:10
        shift!(w)
    end
    grove_coordinates(w) |> sum
end

parse_input() |> solve_p2