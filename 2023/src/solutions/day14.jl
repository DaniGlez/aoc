function section_bounds(col)
    h = length(col)
    fixed_idxs = [0]
    append!(fixed_idxs, findall(==('#'), col))
    push!(fixed_idxs, h + 1)
    zip(fixed_idxs[1:end-1] .+ 1, fixed_idxs[2:end] .- 1)
end

column_load(col) = sum(lu -> section_contrib(col, lu...), section_bounds(col))

function section_contrib(col, l, u)
    l > u && return 0
    h = length(col)
    c = count(==('O'), col[l:u])
    c * (h - l + 1) - (c * (c - 1)) ÷ 2
end

fetch_map(path="2023/inputs/input14.txt") = stack(split(read(path, String), "\n") .|> collect, dims=1)
sum(column_load, eachcol(fetch_map()))

# ------ Part 2 ------
preprocess_section_ranges(M) = (eachcol, eachrow) .|> f -> map(f(M)) do cols_or_rows
    section_bounds(cols_or_rows) .|> t -> UnitRange(t...)
end

function cycle_map!(M::BitMatrix, sr)
    shift_ud!(M, sr, :north)
    shift_lr!(M, sr, :west)
    shift_ud!(M, sr, :south)
    shift_lr!(M, sr, :east)
end

shift_ud!(M, sr, dir) = map(idx -> shift_ud_col!(M, sr, dir, idx), 1:size(M)[2])
shift_lr!(M, sr, dir) = map(idx -> shift_lr_row!(M, sr, dir, idx), 1:size(M)[1])

function shift_ud_col!(M, sr, dir, col_idx)
    map(rows -> shift_section!(M, rows, col_idx, dir), sr[1][col_idx])
end

function shift_lr_row!(M, sr, dir, row_idx)
    map(cols -> shift_section!(M, row_idx, cols, dir), sr[2][row_idx])
end

function shift_section!(M, rows, cols, dir)
    section = @view M[rows, cols]
    c, v_first = if dir ∈ (:north, :west)
        count(section), true
    elseif dir ∈ (:south, :east)
        length(section) - count(section), false
    end
    section[1:c] .= v_first
    section[c+1:end] .= !v_first
    nothing
end

total_load(M) = sum(col -> sum((length(col) + 1) .- findall(==(true), col)), eachcol(M))

function solve(C)
    section_ranges = preprocess_section_ranges(C)
    M = (C .== 'O')
    history = typeof(M)[]
    N = 1_000_000_000
    for i ∈ 1:N
        cycle_map!(M, section_ranges)
        idx = findfirst(==(M), history)
        if isnothing(idx)
            push!(history, copy(M))
            continue
        end
        supercycle_period = i - idx
        remaining_cycles = N - i
        extra_cycles = remaining_cycles % supercycle_period
        return total_load(history[idx+extra_cycles])
    end
end

fetch_map() |> solve
