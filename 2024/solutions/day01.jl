
function parse_input(input="2024/inputs/day01.txt")
    lists = (Int64[], Int64[])
    for line ∈ eachline(input)
        terms = split(line, "   ")
        push!(lists[1], parse(Int64, terms[1]))
        push!(lists[2], parse(Int64, terms[2]))
    end
    lists
end

function solve_p1(lists)
    left, right = lists
    sort!(left)
    sort!(right)
    sum(zip(left, right)) do (l, r)
        abs(l - r)
    end
end

function solve_p2(lists)
    left, right = lists
    sum(left) do x
        count(==(x), right) * x
    end
end

parse_input() |> solve_p1 |> println
parse_input() |> solve_p2 |> println

# ========= faster P2 =========
# Caching duplicated results does not seem to improve performance

function solve_p2_alt(lists)
    left, right = lists
    sort!(right)
    sum(left) do x
        length(searchsorted(right, x)) * x
    end
end

parse_input() |> solve_p2_alt |> println

using Chairmarks

@b parse_input() solve_p2
@b parse_input() solve_p2_alt

# ========= another version =========
# slower :(

function parse_to_vec_of_tuples(input="2024/inputs/day01.txt")
    v_of_t = NTuple{2,Int64}[]
    for line ∈ eachline(input)
        terms = split(line, "   ")
        push!(v_of_t, (parse(Int64, terms[1]), parse(Int64, terms[2])))
    end
    v_of_t
end

function solve_p2_v3(inputs)
    right = Dict{Int64,Int64}()
    left = Dict{Int64,Int64}()
    acc = 0
    for (r, l) ∈ inputs
        right[r] = get(right, r, 0) + 1
        acc += r * get(left, r, 0)
        left[l] = get(left, l, 0) + 1
        acc += l * get(right, l, 0)
    end
    acc
end

parse_to_vec_of_tuples() |> solve_p2_v3 |> println

@b parse_input() solve_p2
@b parse_to_vec_of_tuples() solve_p2_v3

# ========= another version =========

function popcount!(x::Vector{Int64})
    isempty(x) && return 0, 0
    n = 1
    val = pop!(x)
    while !isempty(x) && last(x) == val
        n += 1
        pop!(x)
    end
    n, val
end

function solve_p2_v4(lists)
    left, right = lists
    sort!(right)
    sort!(left)
    nᵣ, rval = popcount!(right)
    nₗ, lval = popcount!(left)
    acc = 0
    while !isempty(right) || !isempty(left)
        if rval == lval
            acc += nᵣ * nₗ * rval
            nᵣ, rval = popcount!(right)
            nₗ, lval = popcount!(left)
        elseif rval < lval
            nₗ, lval = popcount!(left)
        else
            nᵣ, rval = popcount!(right)
        end
    end
    acc
end

parse_input() |> solve_p2_v4 |> println

@b parse_input() solve_p2_v4