function parse_input(filename="2024/inputs/day23.txt")
    return map(x -> Symbol.(split(x, '-')), eachline(filename)) .|> Tuple
end

parse_input()

function connections(data::Vector{NTuple{2,T}}, ::Val{part1}) where {T,part1}
    all_machines = Set{T}()
    conmap = Dict{T,Vector{T}}()
    triplets = Vector{NTuple{3,T}}()
    for connection ∈ data
        a, b = connection
        if part1
            for c ∈ all_machines
                c ∈ (a, b) && continue
                if a ∈ conmap[c] && b ∈ conmap[c]
                    push!(triplets, (a, b, c))
                end
            end
        end
        push!(get!(conmap, a, Vector{T}()), b)
        push!(get!(conmap, b, Vector{T}()), a)
        push!(all_machines, a)
        push!(all_machines, b)
    end
    if part1
        filter(triplets) do tr
            any(m -> startswith(String(m), 't'), tr)
        end |> length
    else
        conmap, all_machines
    end
end

solve_p1(data) = connections(data, Val(true))
solve_p1(parse_input()) |> println

function bk!(conmap, C, R::Set{T}, P::Set{T}, X::Set{T}) where {T}
    if isempty(P) && isempty(X)
        push!(C, R)
    end
    for v ∈ P
        N = Set(conmap[v])
        bk!(conmap, C, R ∪ Set([v]), P ∩ N, Set{T}(X ∩ N))
        P = filter(x -> x != v, P)
        X = X ∪ Set([v])
    end
end

function solve_p2(data::Vector{NTuple{2,T}}) where {T}
    conmap, machines = connections(data, Val(false))
    clusters = Vector{Set{T}}()
    bk!(conmap, clusters, Set{T}(), machines, Set{T}())
    clmax = argmax(length, clusters) |> collect
    sort!(clmax)
    join(clmax, ',')
end

solve_p2(parse_input("2024/examples/day23.txt"))
solve_p2(parse_input("2024/inputs/day23.txt"))
