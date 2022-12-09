using Pipe, StaticArrays, Accessors

# parse input
pline(line) = @pipe collect(line) .|> parse(Int64, _)

function input_trees()
    open("src/inputs/day8.txt") do f
        return @pipe readlines(f) .|> pline |> hcat(_...) |> transpose
    end
end

function example_trees()
    [
        3 0 3 7 3
        2 5 5 1 2
        6 5 3 3 2
        3 3 5 4 9
        3 5 3 9 0
    ]
end

# part 1
# create visibility mask
function proc_vmask!(trees, vmask, dir, dim, vbase)
    other_dim = 3 - dim
    S = size(trees)
    for j ∈ 1:S[other_dim]
        v = vbase
        for i ∈ 1:S[dim]
            k = i
            if dir == -1
                k = S[dim] + 1 - i
            end
            idx = (j, j)
            idx = @set idx[dim] = k
            height = trees[idx...]
            if height > v
                vmask[idx...] = true
                v = height
            end
        end
    end
end

function visibility_mask(trees)
    vbase = minimum(trees) - 1
    vmask = zeros(Bool, size(trees)...)
    for dim ∈ (1, 2)
        for dir ∈ (1, -1)
            proc_vmask!(trees, vmask, dir, dim, vbase)
        end
    end
    vmask
end

visible_trees(trees) = visibility_mask(trees) |> sum
@assert 21 == example_trees() |> visible_trees
input_trees() |> visible_trees |> println

# part 2
function proc_vdist!(trees, view_dist, dirdim, ::Val{hₘₐₓ₁}) where {hₘₐₓ₁}
    dim = (dirdim - 1) ÷ 2 + 1
    dir = -1 + 2 * (dirdim % 2)
    other_dim = 3 - dim
    S = size(trees)
    last_seen = MVector{hₘₐₓ₁,Int64}(undef)
    for j ∈ 1:S[other_dim]
        fill!(last_seen, 1)
        for i ∈ 1:S[dim]
            k = i
            if dir == -1
                k = S[dim] + 1 - i
            end
            idx = (j, j)
            idx = @set idx[dim] = k
            height = trees[idx...]
            view_dist[(idx..., dirdim)...] = (i - last_seen[height+1])
            last_seen[1:height+1] .= i
        end
    end
    nothing
end

function compute_vdist(trees)
    view_distance = zeros(Int64, (size(trees)..., 4))
    bounds = (minimum(trees), maximum(trees))
    @assert bounds[1] == 0
    for dirdim ∈ 1:4
        proc_vdist!(trees, view_distance, dirdim, Val(bounds[2] + 1))
    end
    view_distance
end

function max_score(trees)
    view_distance = compute_vdist(trees)
    scenic_score = .*((@pipe 1:4 .|> view_distance[:, :, _])...)
    maximum(scenic_score)
end

@assert max_score(example_trees()) == 8
input_trees() |> max_score |> println