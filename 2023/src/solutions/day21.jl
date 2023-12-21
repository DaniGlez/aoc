const CI = CartesianIndex
const N, E, S, W = CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1)

fetch_map(path="2023/inputs/input21.txt") = stack(readlines(path) .|> collect, dims=1)

neighbours(ci::CI{2}) = map(Δ -> ci + Δ, (N, E, S, W))

function reach_n(M; entry_point=nothing, steps=64)
    start = isnothing(entry_point) ? findfirst(==('S'), M) : entry_point
    (h, w) = size(M)
    distances = Matrix{Int64}(undef, (h, w))
    distances .= typemax(Int64)
    distances[start] = 0
    for d ∈ 0:(steps-1)
        garden_plots_to_explore = findall(==(d), distances)
        isempty(garden_plots_to_explore) && break
        for x ∈ garden_plots_to_explore
            for n ∈ neighbours(x)
                n ∈ CartesianIndices(distances) || continue
                M[n] == '#' && continue
                distances[n] = min(distances[n], d + 1)
            end
        end
    end
    distances
end

function count_n(M; entry_point=nothing, steps=64)
    target_range = iseven(steps) ? (0:2:steps) : (1:2:steps)
    count(in(target_range), reach_n(M; entry_point=entry_point, steps=steps))
end

solve_p1(x) = count_n(x)

fetch_map() |> solve_p1 |> println

# ------ Part 2 ------

function solve_p2(M0; total_steps=26_501_365)
    M = replace(M0, 'S' => '.')
    (h, w) = size(M)
    @assert h == w
    midpoint = (h + 1) ÷ 2
    # These next facts substantially simplify the problem
    # The reachability front will *always* arrive from a garden edge midpoint
    # in the spoke (see later) or a corner otherwise, and always reach any point 
    # in the boundary from there at least as quickly as from any other front arrival point
    @assert all(==('.'), M[midpoint, :])
    @assert all(==('.'), M[:, midpoint])

    steps_white_tile = count_n(M0; steps=h * w)
    steps_black_tile = count_n(M0; steps=h * w + 1)
    @show steps_white_tile
    @show steps_black_tile

    # The "spoke" is the segment of fully reached cells in each cardinal direction
    # from the origin block, not including it
    spoke_length = (total_steps - midpoint) ÷ h

    # full cells - checked that all reachable points are reached in the time it
    # takes the front to cross from corner to corner
    full_black = (2 * (spoke_length ÷ 2) + 1)^2
    full_white = 4 * ((spoke_length + 1) ÷ 2)^2
    isodd(total_steps) && ((full_black, full_white) = (full_white, full_black))
    total_cells = full_black * steps_black_tile + full_white * steps_white_tile
    @show total_cells

    # spoke tips
    # remaining steps at spoke
    rem_steps = total_steps - spoke_length * h - midpoint
    @show rem_steps
    @show spoke_length
    @show full_black
    @show full_white

    # spoke tips
    top, bot, left, right = CI(1, midpoint), CI(h, midpoint), CI(midpoint, 1), CI(midpoint, w)
    for entry_point ∈ (top, bot, left, right)
        @show count_n(M; entry_point=entry_point, steps=rem_steps)
        total_cells += count_n(M; entry_point=entry_point, steps=rem_steps)
        @show total_cells
    end

    # remaining cells at inner corners
    rem_steps_inner = rem_steps + midpoint - 1
    rem_steps_outer = rem_steps_inner - h
    @show rem_steps_inner
    @show rem_steps_outer
    for entry_point ∈ (CI(1, 1), CI(1, w), CI(h, 1), CI(h, w))
        # Inner diagonal blocks
        inner_cells = count_n(M; entry_point=entry_point, steps=rem_steps_inner)
        @show inner_cells
        total_cells += spoke_length * inner_cells

        rem_steps_outer >= 0 || continue
        outer_cells = count_n(M; entry_point=entry_point, steps=rem_steps_outer)
        @show outer_cells
        # Outer diagonal blocks
        total_cells += (spoke_length + 1) * outer_cells
    end
    total_cells
end

using Test
@testset "Dummy test" begin
    Mtest_3x3 = ['.' '.' '.'; '.' 'S' '.'; '.' '.' '.']
    Mtest_5x5 = ['.' '.' '.' '.' '.'; '.' '.' '.' '.' '.'; '.' '.' 'S' '.' '.'; '.' '.' '.' '.' '.'; '.' '.' '.' '.' '.']
    for n ∈ 3:100
        @test solve_p2(Mtest_3x3; total_steps=n) == (n + 1)^2
        @test solve_p2(Mtest_5x5; total_steps=n) == (n + 1)^2
    end
end

fetch_map() |> solve_p2