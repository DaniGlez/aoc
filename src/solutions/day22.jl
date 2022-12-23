const BLOCK = '#'
const CI₂ = CartesianIndex{2}
const up = CI₂(-1, 0)
const down = CI₂(1, 0)
const right = CI₂(0, 1)
const left = CI₂(0, -1)
const dirs = (right, down, left, up)
res_value(dir) = findfirst(d -> d == dir, dirs) - 1
x_pos(ci::CI₂) = ci.I[2]
y_pos(ci::CI₂) = ci.I[1]

struct ForceField{H,W}
    cmap::Matrix{Char}
    wormholes::Dict{CI₂,CI₂}
end

wrap_ci(::ForceField{H,W}, ci) where {H,W} = CI₂(mod1(y_pos(ci), H), mod1(x_pos(ci), W))

function next!(ff::ForceField, ci, Δci)
    next_ci = wrap_ci(ff, ci + Δci)
    (ff.cmap[next_ci] != ' ') && return next_ci
    try
        next_ci = ff.wormholes[next_ci]
        return next_ci
    catch
        seeker_ci = wrap_ci(ff, next_ci + Δci)
        while ff.cmap[seeker_ci] == ' '
            seeker_ci = wrap_ci(ff, seeker_ci + Δci)
        end
        ff.wormholes[next_ci] = seeker_ci
        ff.wormholes[wrap_ci(ff, seeker_ci - Δci)] = ci
        seeker_ci
    end
end

function ForceField(cmap)
    H, W = size(cmap)
    ForceField{H,W}(cmap, Dict{CI₂,CI₂}())
end

function parse_path(sline)
    facing = right
    re = r"(\d+)([RL])"
    dir_idx = 1
    seq = Vector{Tuple{Int64,CI₂}}()
    for m in eachmatch(re, sline)
        n_steps = parse(Int64, m.captures[1])
        turn = m.captures[2]
        Δdir_idx = (turn[1] == 'R') ? 1 : -1
        dir_idx = mod1(dir_idx + Δdir_idx, 4)
        push!(seq, (n_steps, facing))
        facing = dirs[dir_idx]
    end
    last_nsteps = parse(Int64, match(r"([RL])(\d+)", sline).captures[end])
    push!(seq, (last_nsteps, facing))
    seq
end

function parse_input(fpath="src/inputs/day22.txt")
    width = 0
    let force_field, zero_line
        for sline ∈ eachline(fpath)
            (length(sline) == 0) && continue
            isdigit(sline[1]) && return (permutedims(force_field),
                parse_path(sline))
            line = collect(sline)
            if (width == 0)
                width = length(line)
                force_field = line
                zero_line = collect(' ' for _ ∈ 1:width)
            else
                force_field = hcat(force_field, zero_line)
                L = length(line)
                force_field[1:L, end] .= line
            end
        end
    end
end


function solve_p1(ff, seq)
    force_field = ForceField(ff)
    ci = CI₂(1, 1)
    while force_field.cmap[ci] == ' '
        ci += right
    end
    ffacing = right
    for (n_steps, facing) ∈ seq
        for _ ∈ 1:n_steps
            next_ci = next!(force_field, ci, facing)
            (force_field.cmap[next_ci] == BLOCK) && break
            ci = next_ci
        end
        ffacing = facing
    end
    return 1000y_pos(ci) + 4x_pos(ci) + res_value(ffacing)
end

solve_p1(parse_input()...) |> println

# PART PAIN. JUST PAIN
const BLOCK = '#'
const CI₂ = CartesianIndex{2}
const up = CI₂(-1, 0)
const down = CI₂(1, 0)
const right = CI₂(0, 1)
const left = CI₂(0, -1)
const dirs = (right, down, left, up)
res_value(dir) = findfirst(d -> d == dir, dirs) - 1
x_pos(ci::CI₂) = ci.I[2]
y_pos(ci::CI₂) = ci.I[1]

const T₂CI₂ = Tuple{CI₂,CI₂}
struct ForceDice{H,W}
    cmap::Matrix{Char}
    wormholes::Dict{T₂CI₂,T₂CI₂}
end

function ForceDice(cmap)
    H, W = size(cmap)
    ForceDice{H,W}(cmap, Dict{T₂CI₂,T₂CI₂}())
end


function glue_sides!(ff::ForceDice{H,W}, r1, r2, dir1, dir2) where {H,W}
    for (c1, c2) ∈ zip(r1, r2)
        ff.wormholes[(c1, dir1)] = (c2, -dir2)
        ff.wormholes[(c2, dir2)] = (c1, -dir1)
    end
end

function wrap_dice!(ff::ForceDice{H,W}) where {H,W}
    D = (H > 20) ? 50 : 4 # side length
    glue_sides!(ff, CI₂(D + 1, D + 1):CI₂(2D, D + 1), CI₂(2D + 1, 1):CI₂(2D + 1, D), left, up)
    glue_sides!(ff, CI₂(1, D + 1):CI₂(D, D + 1), reverse(CI₂(2D + 1, 1):CI₂(3D, 1)), left, left)
    glue_sides!(ff, CI₂(D + 1, 2D):CI₂(2D, 2D), CI₂(D, 2D + 1):CI₂(D, 3D), right, down)
    glue_sides!(ff, reverse(CI₂(1, 3D):CI₂(D, 3D)), CI₂(2D + 1, 2D):CI₂(3D, 2D), right, right)
    glue_sides!(ff, CI₂(3D + 1, D):CI₂(4D, D), CI₂(3D, D + 1):CI₂(3D, 2D), right, down)
    glue_sides!(ff, CI₂(1, 2D + 1):CI₂(1, 3D), CI₂(4D, 1):CI₂(4D, D), up, down)
    glue_sides!(ff, CI₂(3D + 1, 1):CI₂(4D, 1), CI₂(1, D + 1):CI₂(1, 2D), left, up)
end

function dice_next(ff::ForceDice, ci, Δci)
    try
        return ff.wormholes[(ci, Δci)]
    catch
        nothing
    end
    (ci + Δci, Δci)
end

function parse_path_2(sline)
    re = r"(\d+)([RL])"
    seq = Vector{Tuple{Int64,Char}}()
    for m in eachmatch(re, sline)
        n_steps = parse(Int64, m.captures[1])
        turn = m.captures[2][1]
        push!(seq, (n_steps, turn))
    end
    last_nsteps = parse(Int64, match(r"([RL])(\d+)", sline).captures[end])
    push!(seq, (last_nsteps, 'C'))
    seq
end


const next_dir = Dict(
    (up, 'R') => right,
    (right, 'R') => down,
    (down, 'R') => left,
    (left, 'R') => up,
    (up, 'L') => left,
    (left, 'L') => down,
    (down, 'L') => right,
    (right, 'L') => up,
)

function parse_input_2(fpath="src/inputs/day22.txt")
    width = 0
    let force_field, zero_line
        for sline ∈ eachline(fpath)
            (length(sline) == 0) && continue
            isdigit(sline[1]) && return (permutedims(force_field),
                parse_path_2(sline))
            line = collect(sline)
            if (width == 0)
                width = length(line)
                force_field = line
                zero_line = collect(' ' for _ ∈ 1:width)
            else
                force_field = hcat(force_field, zero_line)
                L = length(line)
                force_field[1:L, end] .= line
            end
        end
    end
end

function solve_p2(ff, seq)
    dice = ForceDice(ff)
    wrap_dice!(dice)
    ci = CI₂(1, 1)
    while dice.cmap[ci] == ' '
        ci += right
    end
    facing = right
    for (n_steps, turn) ∈ seq
        for _ ∈ 1:n_steps
            next_ci, next_facing = dice_next(dice, ci, facing)
            (dice.cmap[next_ci] == BLOCK) && break
            ci = next_ci
            facing = next_facing
        end
        (turn == 'C') && return 1000y_pos(ci) + 4x_pos(ci) + res_value(facing)
        facing = next_dir[(facing, turn)]
    end

end

solve_p2(parse_input_2()...) |> println