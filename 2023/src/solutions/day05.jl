using Pipe

struct Map
    source_destination::Tuple{Symbol,Symbol}
    indexes::Vector{NTuple{2,UnitRange{Int64}}}
end

Map(s::Symbol, d::Symbol) = Map((s, d), NTuple{2,UnitRange{Int64}}[])
Base.push!(m::Map, src_range, dest_range) = push!(m.indexes, (src_range, dest_range))

function (m::Map)(x::Int64)
    for (source_range, destination_range) ∈ m.indexes
        i = findfirst(==(x), source_range)
        !isnothing(i) && return destination_range[i]
    end
    x
end

s2int(x) = parse(Int64, x)
function parse_input(path="2023/inputs/input05.txt")
    seeds = Int64[]
    mappings = Map[]
    source, destination = :uninitialized, :uninitialized
    for line ∈ eachline(path)
        isempty(line) && continue
        if startswith(line, "seeds")
            @pipe eachmatch(r"(\d+)", line) .|> _.captures[1] .|> s2int .|> push!(seeds, _)
        elseif line[1] ∉ '0':'9'
            source, destination = Symbol.(match(r"([a-z]+)-to-([a-z]+) map", line).captures)
            push!(mappings, Map(source, destination))
        else
            dest, src, rlength = @pipe eachmatch(r"(\d+)", line) .|> _.captures[1] .|> s2int
            src_range = src:(src+rlength-1)
            dest_range = dest:(dest+rlength-1)
            push!(last(mappings), src_range, dest_range)
        end
    end
    seeds, mappings
end

seeds_p1, mappings = parse_input()
seed2loc = ∘(reverse(mappings)...)
minimum(seed2loc, seeds_p1) |> println

# ------ Part 2 ------
# Brute force

p2_seed_ranges = zip(seeds_p1[1:2:end], seeds_p1[2:2:end]) |> collect .|> t -> UnitRange(t[1], t[1] + t[2] - 1)
#minimum((r -> minimum(seed2loc, r)).(p2_seed_ranges)) |> println

# More efficient way by inversion, though still a few secs
reverse_map(m::Map) = Map(m.source_destination |> reverse, reverse.(m.indexes))

loc2seed = ∘(reverse_map.(mappings)...)
begin
    loc = 0
    while true
        seed = loc2seed(loc)
        any(r -> seed ∈ r, p2_seed_ranges) && break
        loc += 1
    end
    println(loc)
end

