function parse_input(path="2023/inputs/input11.txt")
    lines = readlines(path) .|> collect
    stack(lines; dims=1)
end

galaxy_locations(universe) = CartesianIndices(universe) |> filter(ij -> universe[ij] == '#')
distances_from_origin(universe; kwargs...) =
    (eachrow, eachcol) .|> f -> dist_from_orig(universe, f; kwargs...)

dist_from_orig(universe, f; expansion_factor) =
    cumsum(f(universe) .|> v -> ('#' ∈ v) ? 1 : expansion_factor)
intergalactic_distance(dy, dx, a, b) = abs(dy[a.I[1]] - dy[b.I[1]]) + abs(dx[a.I[2]] - dx[b.I[2]])

function solve(universe; expansion_factor=2)
    galaxies = galaxy_locations(universe)
    dy, dx = distances_from_origin(universe; expansion_factor=expansion_factor)
    acc = 0
    for (i, a) ∈ enumerate(galaxies)
        for j ∈ 1:(i-1)
            acc += intergalactic_distance(dy, dx, a, galaxies[j])
        end
    end
    acc
end

parse_input() |> solve |> println
parse_input() |> u -> solve(u; expansion_factor=1_000_000) |> println
