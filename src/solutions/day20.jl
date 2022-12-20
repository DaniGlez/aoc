using Pipe, ValSplit

parse_input(fpath="src/inputs/day20.txt") = @pipe readlines(fpath) .|> parse(Int16, _)
example_input = Int16[1, 2, -3, 3, -2, 0, 4]

mutable struct WrappyVector{N,T}
    values::Vector{T}
    successors::Vector{T}
    predecessors::Vector{T}
    zero_idx::T
    first::T
    function WrappyVector(values::Vector{T}) where {T}
        N = length(values)
        successors = T.(mod1.((2:(N+1)), N))
        predecessors = T.(mod1.((N:(2N-1)), N))
        zero_idx = findfirst(v -> v == 0, values)
        new{N,T}(values, successors, predecessors, zero_idx, one(T))
    end
end

s_or_p(w::WrappyVector, s) = (s < 0) ? w.predecessors : w.successors
neighbours(w, i) = (w.predecessors[i], w.successors[i])

function jump(vector, i, n_jumps, ji)
    ji_crosses = 0
    for _ ∈ 1:n_jumps
        (i == ji) && (ji_crosses += 1)
        i = vector[i]
    end
    i, ji_crosses
end

function jump(vector, i, n_jumps)
    for _ ∈ 1:n_jumps
        i = vector[i]
    end
    i
end

function shift_origin!(w::WrappyVector, s)
    (s == 1) && (w.first = w.successors[w.first])
    (s == -1) && (w.first = w.predecessors[w.first])
end

function shift!(w::WrappyVector{N,T}) where {N,T}
    for (i, v) ∈ enumerate(w.values)
        #printw(w)
        v == 0 && continue
        s = sign(v)
        m = abs(v)
        cyclic_shifts = (m ÷ (N - 1)) % N
        side = s_or_p(w, s)
        w.first = jump(side, w.first, cyclic_shifts)
        rem_shift = m % (N - 1)
        cross_index = w.first
        (s == -1) && (cross_index = w.predecessors[cross_index])
        j, origin_crosses = jump(side, i, rem_shift, cross_index)
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
        #println("i=$i, j=$j, s=$s, fi=$(w.first)")
        #print("    Post reweave: ")
        #printw(w)
        if (w.first == i)
            (s > 0) && (w.first = s_i)
            (s < 0) && (w.first = p_i)
        elseif (w.first == j)
            (s > 0) && (w.first = i)
            # elseif (s < 0)
            #     shift_origin!(w, s * origin_crosses)
        end
        #print("    Post origshift: ")
        #printw(w)
    end
end

function grove_coordinates(w)
    a = jump(w.successors, w.zero_idx, 1000)
    b = jump(w.successors, a, 1000)
    c = jump(w.successors, b, 1000)
    (a, b, c) .|> i -> w.values[i]
end

function printw(w::WrappyVector{N}) where {N}
    #print("[")
    i = w.first
    for j ∈ 1:N
        #print("$(w.values[i])")
        #(j < N) && print(", ")
        i = w.successors[i]
    end
    #println("]")
end

function solve_p1(nums)
    w = WrappyVector(nums)
    shift!(w)
    printw(w)
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